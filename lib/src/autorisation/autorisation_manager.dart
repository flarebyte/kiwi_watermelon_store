import 'capability.dart';

/// Evaluates access rights for data operations based on defined capabilities.
class KiwiWatermelonAutorisationManager {
  /// List of configured access capabilities.
  final List<KiwiWatermelonDataCapability> capabilities;

  /// Constructs the authorization manager with a list of capability rules.
  KiwiWatermelonAutorisationManager({required this.capabilities});

  /// Returns `true` if [role] can perform [access] on [key].
  ///
  /// A matching `deny` capability takes precedence over any `allow`.
  bool canInvoke({
    required String role,
    required String key,
    required KiwiWatermelonDataAccess access,
  }) {
    final matching = capabilities.where((cap) =>
        cap.role == role && key.startsWith(cap.prefix) && cap.access == access);

    if (matching.any((cap) => cap.effect == KiwiWatermelonPolicyEffect.deny)) {
      return false;
    }

    return matching
        .any((cap) => cap.effect == KiwiWatermelonPolicyEffect.allow);
  }

  /// Returns `true` if any role has permission to perform [access] on [key].
  ///
  /// Deny rules take precedence over allow.
  bool canAnyRoleInvoke({
    required String key,
    required KiwiWatermelonDataAccess access,
  }) {
    final matching = capabilities
        .where((cap) => key.startsWith(cap.prefix) && cap.access == access);

    if (matching.any((cap) => cap.effect == KiwiWatermelonPolicyEffect.deny)) {
      return false;
    }

    return matching
        .any((cap) => cap.effect == KiwiWatermelonPolicyEffect.allow);
  }

  /// Returns `true` if [role] can read [key].
  bool canRead({required String role, required String key}) {
    return canInvoke(
      key: key,
      access: KiwiWatermelonDataAccess.read,
      role: role,
    );
  }

  /// Returns `true` if [role] can write [key].
  bool canWrite({required String role, required String key}) {
    return canInvoke(
      key: key,
      access: KiwiWatermelonDataAccess.write,
      role: role,
    );
  }

  /// Returns `true` if [role] can delete [key].
  bool canDelete({required String role, required String key}) {
    return canInvoke(
      key: key,
      access: KiwiWatermelonDataAccess.delete,
      role: role,
    );
  }

  /// Returns `true` if [role] has both read and write access to [key].
  bool canReadAndWrite({required String role, required String key}) {
    return canRead(role: role, key: key) && canWrite(role: role, key: key);
  }

  /// Returns `true` if [role] has read, write, and delete access to [key].
  bool canReadWriteDelete({required String role, required String key}) {
    return canRead(role: role, key: key) &&
        canWrite(role: role, key: key) &&
        canDelete(role: role, key: key);
  }
}
