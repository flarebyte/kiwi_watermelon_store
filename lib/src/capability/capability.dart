/// Represents the type of data access requested.
enum KiwiWatermelonDataAccess {
  read,
  write,
  delete,
}

/// Describes the effect of a capability rule.
///
/// Use `deny` to explicitly prohibit an operation; deny rules override allow rules.
enum KiwiWatermelonPolicyEffect {
  allow,
  deny,
}

/// Defines an access capability for a given role, key prefix, access type, and effect.
class KiwiWatermelonDataCapability {
  /// The name of the role to which this capability applies.
  final String role;

  /// Key prefix indicating the resource scope this capability governs.
  final String prefix;

  /// Type of access granted or denied.
  final KiwiWatermelonDataAccess access;

  /// The policy effect (allow or deny) for this capability.
  final KiwiWatermelonPolicyEffect effect;

  /// Creates a new data capability for a specific role, prefix, access type, and effect.
  KiwiWatermelonDataCapability({
    required this.role,
    required this.prefix,
    required this.access,
    required this.effect,
  });

  /// Creates a read capability with an optional [effect] (defaults to [KiwiWatermelonPolicyEffect.allow]).
  static KiwiWatermelonDataCapability read({
    required String role,
    required String prefix,
    KiwiWatermelonPolicyEffect effect = KiwiWatermelonPolicyEffect.allow,
  }) {
    return KiwiWatermelonDataCapability(
      role: role,
      prefix: prefix,
      access: KiwiWatermelonDataAccess.read,
      effect: effect,
    );
  }

  /// Creates a write capability with an optional [effect] (defaults to [KiwiWatermelonPolicyEffect.allow]).
  static KiwiWatermelonDataCapability write({
    required String role,
    required String prefix,
    KiwiWatermelonPolicyEffect effect = KiwiWatermelonPolicyEffect.allow,
  }) {
    return KiwiWatermelonDataCapability(
      role: role,
      prefix: prefix,
      access: KiwiWatermelonDataAccess.write,
      effect: effect,
    );
  }

  /// Creates a delete capability with an optional [effect] (defaults to [KiwiWatermelonPolicyEffect.allow]).
  static KiwiWatermelonDataCapability delete({
    required String role,
    required String prefix,
    KiwiWatermelonPolicyEffect effect = KiwiWatermelonPolicyEffect.allow,
  }) {
    return KiwiWatermelonDataCapability(
      role: role,
      prefix: prefix,
      access: KiwiWatermelonDataAccess.delete,
      effect: effect,
    );
  }

  /// Creates both read and write capabilities.
  static List<KiwiWatermelonDataCapability> readWrite({
    required String role,
    required String prefix,
    KiwiWatermelonPolicyEffect effect = KiwiWatermelonPolicyEffect.allow,
  }) {
    return [
      read(role: role, prefix: prefix, effect: effect),
      write(role: role, prefix: prefix, effect: effect),
    ];
  }

  /// Creates read, write, and delete capabilities.
  static List<KiwiWatermelonDataCapability> readWriteDel({
    required String role,
    required String prefix,
    KiwiWatermelonPolicyEffect effect = KiwiWatermelonPolicyEffect.allow,
  }) {
    return [
      read(role: role, prefix: prefix, effect: effect),
      write(role: role, prefix: prefix, effect: effect),
      delete(role: role, prefix: prefix, effect: effect),
    ];
  }
}

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
