import 'package:kiwi_watermelon_store/src/autorisation/autorisation_manager.dart';
import 'package:kiwi_watermelon_store/src/autorisation/capability.dart';
import 'package:test/test.dart';

void main() {
  group('KiwiWatermelonAutorisationManager', () {
    const role = 'admin';
    const otherRole = 'guest';
    const key = 'user:123:data';
    const prefix = 'user:123';

    test('allows access when a matching allow capability exists', () {
      final manager = KiwiWatermelonAutorisationManager(
        capabilities: [
          KiwiWatermelonDataCapability.read(role: role, prefix: prefix),
        ],
      );

      expect(manager.canRead(role: role, key: key), isTrue);
    });

    test('denies access when no matching capability exists', () {
      final manager = KiwiWatermelonAutorisationManager(
        capabilities: [],
      );

      expect(manager.canRead(role: role, key: key), isFalse);
    });

    test('supports combined read and write checks', () {
      final manager = KiwiWatermelonAutorisationManager(
        capabilities: KiwiWatermelonDataCapability.readWrite(
          role: role,
          prefix: prefix,
        ),
      );

      expect(manager.canReadAndWrite(role: role, key: key), isTrue);
    });

    test('allows any role if matching capability exists', () {
      final manager = KiwiWatermelonAutorisationManager(
        capabilities: [
          KiwiWatermelonDataCapability.read(role: otherRole, prefix: prefix),
        ],
      );

      expect(
          manager.canAnyRoleInvoke(
            key: key,
            access: KiwiWatermelonDataAccess.read,
          ),
          isTrue);
    });

    test('canDelete returns true if delete is allowed', () {
      final manager = KiwiWatermelonAutorisationManager(
        capabilities: [
          KiwiWatermelonDataCapability.delete(role: 'admin', prefix: 'res:'),
        ],
      );

      expect(manager.canDelete(role: 'admin', key: 'res:item1'), isTrue);
    });

    test('canDelete returns false if delete is denied', () {
      final manager = KiwiWatermelonAutorisationManager(
        capabilities: [
          KiwiWatermelonDataCapability.delete(
            role: 'admin',
            prefix: 'res:',
            effect: KiwiWatermelonPolicyEffect.deny,
          ),
        ],
      );

      expect(manager.canDelete(role: 'admin', key: 'res:item1'), isFalse);
    });

    test('canReadWriteDelete returns true when all capabilities are allowed',
        () {
      final manager = KiwiWatermelonAutorisationManager(
        capabilities: KiwiWatermelonDataCapability.readWriteDel(
          role: 'admin',
          prefix: 'doc:',
        ),
      );

      expect(
          manager.canReadWriteDelete(role: 'admin', key: 'doc:page1'), isTrue);
    });

    test('canReadWriteDelete returns false if one capability is denied', () {
      final caps = KiwiWatermelonDataCapability.readWriteDel(
        role: 'admin',
        prefix: 'doc:',
      );

      // Override write to be denied
      final modified = [
        caps[0], // read (allow)
        KiwiWatermelonDataCapability.write(
          role: 'admin',
          prefix: 'doc:',
          effect: KiwiWatermelonPolicyEffect.deny,
        ),
        caps[2], // delete (allow)
      ];

      final manager = KiwiWatermelonAutorisationManager(capabilities: modified);

      expect(
          manager.canReadWriteDelete(role: 'admin', key: 'doc:page1'), isFalse);
    });

    group('edge cases', () {
      test('deny overrides allow when both exist for the same role/key/access',
          () {
        final manager = KiwiWatermelonAutorisationManager(
          capabilities: [
            KiwiWatermelonDataCapability.read(
              role: role,
              prefix: prefix,
              effect: KiwiWatermelonPolicyEffect.allow,
            ),
            KiwiWatermelonDataCapability.read(
              role: role,
              prefix: prefix,
              effect: KiwiWatermelonPolicyEffect.deny,
            ),
          ],
        );

        expect(manager.canRead(role: role, key: key), isFalse);
      });

      test('deny overrides allow for overlapping prefix match', () {
        final manager = KiwiWatermelonAutorisationManager(
          capabilities: [
            KiwiWatermelonDataCapability.read(
              role: role,
              prefix: 'user:',
              effect: KiwiWatermelonPolicyEffect.allow,
            ),
            KiwiWatermelonDataCapability.read(
              role: role,
              prefix: 'user:123',
              effect: KiwiWatermelonPolicyEffect.deny,
            ),
          ],
        );

        expect(manager.canRead(role: role, key: key), isFalse);
      });

      test('does not apply deny from unrelated role', () {
        final manager = KiwiWatermelonAutorisationManager(
          capabilities: [
            KiwiWatermelonDataCapability.read(
              role: role,
              prefix: prefix,
              effect: KiwiWatermelonPolicyEffect.allow,
            ),
            KiwiWatermelonDataCapability.read(
              role: otherRole,
              prefix: prefix,
              effect: KiwiWatermelonPolicyEffect.deny,
            ),
          ],
        );

        expect(manager.canRead(role: role, key: key), isTrue);
      });

      test('canAnyRoleInvoke respects deny precedence', () {
        final manager = KiwiWatermelonAutorisationManager(
          capabilities: [
            KiwiWatermelonDataCapability.read(
              role: 'r1',
              prefix: prefix,
              effect: KiwiWatermelonPolicyEffect.allow,
            ),
            KiwiWatermelonDataCapability.read(
              role: 'r2',
              prefix: prefix,
              effect: KiwiWatermelonPolicyEffect.deny,
            ),
          ],
        );

        expect(
            manager.canAnyRoleInvoke(
              key: key,
              access: KiwiWatermelonDataAccess.read,
            ),
            isFalse);
      });

      test('longer deny prefix correctly overrides shorter allow prefix', () {
        final manager = KiwiWatermelonAutorisationManager(
          capabilities: [
            KiwiWatermelonDataCapability.read(
              role: role,
              prefix: 'user:',
              effect: KiwiWatermelonPolicyEffect.allow,
            ),
            KiwiWatermelonDataCapability.read(
              role: role,
              prefix: 'user:123:',
              effect: KiwiWatermelonPolicyEffect.deny,
            ),
          ],
        );

        expect(manager.canRead(role: role, key: 'user:123:data'), isFalse);
        expect(manager.canRead(role: role, key: 'user:456:data'), isTrue);
      });
    });
  });
}
