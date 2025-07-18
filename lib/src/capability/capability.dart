enum KiwiWatermelonDataAccess { read, write, delete }

enum KiwiWatermelonPolicyEffect { allow, deny }

// PolicyRule ?
class KiwiWatermelonDataCapability {
  final String role;
  final String prefix;
  final KiwiWatermelonDataAccess access;
  final KiwiWatermelonPolicyEffect effect;

  KiwiWatermelonDataCapability(
      {required this.role,
      required this.prefix,
      required this.access,
      required this.effect});

  static KiwiWatermelonDataCapability read(
      {required String role,
      required String prefix,
      KiwiWatermelonPolicyEffect effect = KiwiWatermelonPolicyEffect.allow}) {
    return KiwiWatermelonDataCapability(
        role: role,
        prefix: prefix,
        access: KiwiWatermelonDataAccess.read,
        effect: effect);
  }

  static KiwiWatermelonDataCapability write(
      {required String role,
      required String prefix,
      effect = KiwiWatermelonPolicyEffect.allow}) {
    return KiwiWatermelonDataCapability(
        role: role,
        prefix: prefix,
        access: KiwiWatermelonDataAccess.write,
        effect: effect);
  }

  static KiwiWatermelonDataCapability delete(
      {required String role,
      required String prefix,
      effect = KiwiWatermelonPolicyEffect.allow}) {
    return KiwiWatermelonDataCapability(
        role: role,
        prefix: prefix,
        access: KiwiWatermelonDataAccess.delete,
        effect: effect);
  }

  static List<KiwiWatermelonDataCapability> readWrite(
      {required String role,
      required String prefix,
      effect = KiwiWatermelonPolicyEffect.allow}) {
    return [
      KiwiWatermelonDataCapability(
          role: role,
          prefix: prefix,
          access: KiwiWatermelonDataAccess.read,
          effect: effect),
      KiwiWatermelonDataCapability(
          role: role,
          prefix: prefix,
          access: KiwiWatermelonDataAccess.write,
          effect: effect)
    ];
  }

  static List<KiwiWatermelonDataCapability> readWriteDel(
      {required String role,
      required String prefix,
      effect = KiwiWatermelonPolicyEffect.allow}) {
    return [
      KiwiWatermelonDataCapability(
          role: role,
          prefix: prefix,
          access: KiwiWatermelonDataAccess.read,
          effect: effect),
      KiwiWatermelonDataCapability(
          role: role,
          prefix: prefix,
          access: KiwiWatermelonDataAccess.write,
          effect: effect),
      KiwiWatermelonDataCapability(
          role: role,
          prefix: prefix,
          access: KiwiWatermelonDataAccess.delete,
          effect: effect)
    ];
  }
}

class KiwiWatermelonAutorisationManager {
  final List<KiwiWatermelonDataCapability> capabilities;

  KiwiWatermelonAutorisationManager({required this.capabilities});

  bool canInvoke(
      {required String role,
      required String key,
      required KiwiWatermelonDataAccess access}) {
    return capabilities.any((capability) =>
        capability.role == role &&
        key.startsWith(capability.prefix) &&
        capability.access == access);
  }

  bool canAnyRoleInvoke(
      {required String key, required KiwiWatermelonDataAccess access}) {
    return capabilities.any((capability) =>
        key.startsWith(capability.prefix) && capability.access == access);
  }

  bool canRead({required String role, required String key}) {
    return canInvoke(
        key: key, access: KiwiWatermelonDataAccess.read, role: role);
  }

  bool canWrite({required String role, required String key}) {
    return canInvoke(
        key: key, access: KiwiWatermelonDataAccess.write, role: role);
  }

  bool canDelete({required String role, required String key}) {
    return canInvoke(
        key: key, access: KiwiWatermelonDataAccess.delete, role: role);
  }

  bool canReadAndWrite({required String role, required String key}) {
    return canRead(key: key, role: role) && canWrite(key: key, role: role);
  }

  bool canReadWriteDelete({required String role, required String key}) {
    return canRead(key: key, role: role) &&
        canWrite(key: key, role: role) &&
        canDelete(key: key, role: role);
  }
}
