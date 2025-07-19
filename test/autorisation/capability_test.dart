import 'package:kiwi_watermelon_store/src/autorisation/capability.dart';
import 'package:test/test.dart';

void main() {
  group('KiwiWatermelonDataCapability', () {
    const role = 'admin';
    const prefix = 'user:123';

    test('creates read capability with default allow effect', () {
      final cap = KiwiWatermelonDataCapability.read(role: role, prefix: prefix);

      expect(cap.role, role);
      expect(cap.prefix, prefix);
      expect(cap.access, KiwiWatermelonDataAccess.read);
      expect(cap.effect, KiwiWatermelonPolicyEffect.allow);
    });

    test('creates write capability with deny effect', () {
      final cap = KiwiWatermelonDataCapability.write(
        role: role,
        prefix: prefix,
        effect: KiwiWatermelonPolicyEffect.deny,
      );

      expect(cap.access, KiwiWatermelonDataAccess.write);
      expect(cap.effect, KiwiWatermelonPolicyEffect.deny);
    });

    test('creates delete capability with default allow effect', () {
      final cap = KiwiWatermelonDataCapability.delete(role: role, prefix: prefix);

      expect(cap.access, KiwiWatermelonDataAccess.delete);
      expect(cap.effect, KiwiWatermelonPolicyEffect.allow);
    });

    test('readWrite factory returns read and write capabilities', () {
      final caps = KiwiWatermelonDataCapability.readWrite(
        role: role,
        prefix: prefix,
        effect: KiwiWatermelonPolicyEffect.allow,
      );

      expect(caps.length, 2);
      expect(caps[0].access, KiwiWatermelonDataAccess.read);
      expect(caps[1].access, KiwiWatermelonDataAccess.write);
      expect(caps.every((c) => c.role == role), isTrue);
    });

    test('readWriteDel factory returns all access types', () {
      final caps = KiwiWatermelonDataCapability.readWriteDel(
        role: role,
        prefix: prefix,
        effect: KiwiWatermelonPolicyEffect.deny,
      );

      expect(caps.length, 3);
      expect(caps.map((c) => c.access), containsAll([
        KiwiWatermelonDataAccess.read,
        KiwiWatermelonDataAccess.write,
        KiwiWatermelonDataAccess.delete,
      ]));
      expect(caps.every((c) => c.effect == KiwiWatermelonPolicyEffect.deny), isTrue);
    });
  });
}

