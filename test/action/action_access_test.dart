import 'package:kiwi_watermelon_store/src/action/action_access.dart';
import 'package:kiwi_watermelon_store/src/autorisation/capability.dart';
import 'package:test/test.dart';

void main() {
  group('KiwiWatermelonActionAccess', () {
    const role = 'admin';
    const otherRole = 'guest';
    const key = 'env:user:123:name:john'; // scope:key1:value1:key2:value2
    const prefix = 'env:user:123';

    late KiwiWatermelonActionAccess access;

    setUp(() {
      access = KiwiWatermelonActionAccess(capabilities: [
        ...KiwiWatermelonDataCapability.readWriteDel(
            role: role, prefix: prefix),
      ]);
    });

    test('grants read/write access for incr operation', () {
      expect(access.incr(key, role: role), isTrue);
    });

    test('denies access for guest role with no capability', () {
      expect(access.incr(key, role: otherRole), isFalse);
    });

    test('allows delete for full key match', () {
      expect(access.del(key, role: role), isTrue);
    });

    test('denies delete if prefix does not match', () {
      expect(access.del('env:user:456:name:alice', role: role), isFalse);
    });

    test('permits rename only if both keys are accessible', () {
      final destKey = 'env:user:123:location:fr';
      expect(access.rename(key, destKey, role: role), isTrue);
    });

    test('denies rename if destination key is not writable', () {
      final access = KiwiWatermelonActionAccess(capabilities: [
        ...KiwiWatermelonDataCapability.readWrite(role: role, prefix: prefix),
        // Destination key is outside allowed prefix
      ]);

      final destKey = 'env:user:999:other:x';
      expect(access.rename(key, destKey, role: role), isFalse);
    });

    test('permits lmove only when both source and destination are authorized',
        () {
      final source = 'env:user:123:friends:list';
      final dest = 'env:user:123:groups:list';
      expect(access.lmove(source, dest, role: role), isTrue);
    });

    test(
        'denies lmove if either source or destination is not covered by prefix',
        () {
      final source = 'env:user:123:friends:list';
      final dest = 'env:user:456:groups:list';
      expect(access.lmove(source, dest, role: role), isFalse);
    });

    test('denies flushDb unless root key is explicitly allowed to delete', () {
      final access = KiwiWatermelonActionAccess(capabilities: [
        KiwiWatermelonDataCapability.delete(role: role, prefix: '__root__'),
      ]);

      expect(access.flushDb(role: role), isTrue);
    });

    test('denies flushDb if root prefix is not granted', () {
      final access = KiwiWatermelonActionAccess(capabilities: [
        KiwiWatermelonDataCapability.delete(role: role, prefix: 'env:user:123'),
      ]);

      expect(access.flushDb(role: role), isFalse);
    });

    test('delKeys is denied if "__pattern__" delete is not allowed', () {
      expect(access.delKeys(role: role), isFalse);
    });

    test('delKeys is allowed when "__pattern__" delete is explicitly granted',
        () {
      final access = KiwiWatermelonActionAccess(capabilities: [
        KiwiWatermelonDataCapability.delete(role: role, prefix: '__pattern__'),
      ]);
      expect(access.delKeys(role: role), isTrue);
    });
  });
}
