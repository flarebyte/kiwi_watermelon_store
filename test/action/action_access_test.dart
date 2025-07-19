import 'package:kiwi_watermelon_store/src/action/action_access.dart';
import 'package:kiwi_watermelon_store/src/autorisation/capability.dart';
import 'package:test/test.dart';

void main() {
  group('KiwiWatermelonActionAccess', () {
    const role = 'admin';
    const key = 'env:user:123:name:john';
    const prefix = 'env:user:123';

    late KiwiWatermelonActionAccess access;

    setUp(() {
      access = KiwiWatermelonActionAccess(capabilities: [
        ...KiwiWatermelonDataCapability.readWriteDel(
            role: role, prefix: prefix),
      ]);
    });

    group('numeric operations', () {
      test('incr allowed with read/write', () {
        expect(access.incr(key, role: role), isTrue);
      });

      test('decr allowed with read/write', () {
        expect(access.decr(key, role: role), isTrue);
      });

      test('incrBy allowed with read/write', () {
        expect(access.incrBy(key, role: role), isTrue);
      });

      test('decrBy allowed with read/write', () {
        expect(access.decrBy(key, role: role), isTrue);
      });

      test('incrByFloat allowed with read/write', () {
        expect(access.incrByFloat(key, role: role), isTrue);
      });

      test('decrByFloat allowed with read/write', () {
        expect(access.decrByFloat(key, role: role), isTrue);
      });
    });

    group('value setters', () {
      test('setInteger allowed with write', () {
        expect(access.setInteger(key, role: role), isTrue);
      });

      test('setDouble allowed with write', () {
        expect(access.setDouble(key, role: role), isTrue);
      });

      test('setUuid allowed with write', () {
        expect(access.setUuid(key, role: role), isTrue);
      });

      test('setEnum allowed with write', () {
        expect(access.setEnum(key, role: role), isTrue);
      });
    });

    group('rename operations', () {
      test('rename allowed when old and new keys are permitted', () {
        final newKey = 'env:user:123:location:fr';
        expect(access.rename(key, newKey, role: role), isTrue);
      });

      test('renamenx allowed when both keys are permitted', () {
        final newKey = 'env:user:123:email:abc';
        expect(access.renamenx(key, newKey, role: role), isTrue);
      });

      test('rename denied if destination is not allowed', () {
        final newKey = 'env:user:999:email:abc';
        expect(access.rename(key, newKey, role: role), isFalse);
      });
    });

    group('list operations', () {
      final listKey = 'env:user:123:list:friends';
      final otherKey = 'env:user:123:list:groups';

      test('lpush allowed with write', () {
        expect(access.lpush(listKey, role: role), isTrue);
      });

      test('rpush allowed with write', () {
        expect(access.rpush(listKey, role: role), isTrue);
      });

      test('lrem allowed with write', () {
        expect(access.lrem(listKey, role: role), isTrue);
      });

      test('ltrim allowed with write', () {
        expect(access.ltrim(listKey, role: role), isTrue);
      });

      test('rpoplpush allowed if both keys permitted', () {
        expect(access.rpoplpush(listKey, otherKey, role: role), isTrue);
      });

      test('lmove allowed if both keys permitted', () {
        expect(access.lmove(listKey, otherKey, role: role), isTrue);
      });

      test('lmove denied if destination is not accessible', () {
        final deniedAccess = KiwiWatermelonActionAccess(capabilities: [
          ...KiwiWatermelonDataCapability.readWrite(
              role: role, prefix: listKey),
        ]);
        expect(
            deniedAccess.lmove(listKey, 'env:user:999:list:groups', role: role),
            isFalse);
      });
    });

    group('set operations', () {
      final setKey = 'env:user:123:set:tags';
      final destKey = 'env:user:123:set:archived';

      test('sadd allowed with write', () {
        expect(access.sadd(setKey, role: role), isTrue);
      });

      test('srem allowed with write', () {
        expect(access.srem(setKey, role: role), isTrue);
      });

      test('smove allowed if both keys permitted', () {
        expect(access.smove(setKey, destKey, role: role), isTrue);
      });

      test('smove denied if destination is not permitted', () {
        final deniedAccess = KiwiWatermelonActionAccess(capabilities: [
          ...KiwiWatermelonDataCapability.readWrite(role: role, prefix: setKey),
        ]);
        expect(
            deniedAccess.smove(setKey, 'env:user:999:set:archive', role: role),
            isFalse);
      });
    });
  });
  group('deletion operations', () {
    const key = 'env:user:123:data:name';
    const role = 'admin';

    test('flushDb allowed when __root__ delete capability exists', () {
      final access = KiwiWatermelonActionAccess(capabilities: [
        KiwiWatermelonDataCapability.delete(role: role, prefix: '__root__'),
      ]);

      expect(access.flushDb(role: role), isTrue);
    });

    test('flushDb denied without __root__ delete capability', () {
      final access = KiwiWatermelonActionAccess(capabilities: [
        KiwiWatermelonDataCapability.delete(role: role, prefix: 'env:user:123'),
      ]);

      expect(access.flushDb(role: role), isFalse);
    });

    test('delKeys allowed when __pattern__ delete capability exists', () {
      final access = KiwiWatermelonActionAccess(capabilities: [
        KiwiWatermelonDataCapability.delete(role: role, prefix: '__pattern__'),
      ]);

      expect(access.delKeys(role: role), isTrue);
    });

    test('delKeys denied without __pattern__ delete capability', () {
      final access = KiwiWatermelonActionAccess(capabilities: [
        KiwiWatermelonDataCapability.delete(role: role, prefix: 'env:user:123'),
      ]);

      expect(access.delKeys(role: role), isFalse);
    });

    test('del returns true if role can delete key', () {
      final access = KiwiWatermelonActionAccess(capabilities: [
        KiwiWatermelonDataCapability.delete(role: role, prefix: 'env:user:123'),
      ]);

      expect(access.del(key, role: role), isTrue);
    });

    test('del returns false if role cannot delete key', () {
      final access = KiwiWatermelonActionAccess(capabilities: [
        KiwiWatermelonDataCapability.delete(role: role, prefix: 'env:user:999'),
      ]);

      expect(access.del(key, role: role), isFalse);
    });

    test('del is denied if effect is explicitly deny', () {
      final access = KiwiWatermelonActionAccess(capabilities: [
        KiwiWatermelonDataCapability.delete(
          role: role,
          prefix: 'env:user:123',
          effect: KiwiWatermelonPolicyEffect.deny,
        ),
      ]);

      expect(access.del(key, role: role), isFalse);
    });
  });
}
