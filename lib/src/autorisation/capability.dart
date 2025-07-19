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

