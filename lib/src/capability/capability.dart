enum KiwiWatermelonDataAccess { read, write, delete }

class KiwiWatermelonDataCapability {
  final String role;
  final String prefix;
  final KiwiWatermelonDataAccess access;

  KiwiWatermelonDataCapability(
      {required this.role, required this.prefix, required this.access});

  static KiwiWatermelonDataCapability read(
      {required String role, required String prefix}) {
    return KiwiWatermelonDataCapability(
        role: role, prefix: prefix, access: KiwiWatermelonDataAccess.read);
  }

  static KiwiWatermelonDataCapability write(
      {required String role, required String prefix}) {
    return KiwiWatermelonDataCapability(
        role: role, prefix: prefix, access: KiwiWatermelonDataAccess.write);
  }

  static KiwiWatermelonDataCapability delete(
      {required String role, required String prefix}) {
    return KiwiWatermelonDataCapability(
        role: role, prefix: prefix, access: KiwiWatermelonDataAccess.delete);
  }

  static List<KiwiWatermelonDataCapability> readWrite(
      {required String role, required String prefix}) {
    return [
      KiwiWatermelonDataCapability(
          role: role, prefix: prefix, access: KiwiWatermelonDataAccess.read),
      KiwiWatermelonDataCapability(
          role: role, prefix: prefix, access: KiwiWatermelonDataAccess.write)
    ];
  }

  static List<KiwiWatermelonDataCapability> readWriteDel(
      {required String role, required String prefix}) {
    return [
      KiwiWatermelonDataCapability(
          role: role, prefix: prefix, access: KiwiWatermelonDataAccess.read),
      KiwiWatermelonDataCapability(
          role: role, prefix: prefix, access: KiwiWatermelonDataAccess.write),
      KiwiWatermelonDataCapability(
          role: role, prefix: prefix, access: KiwiWatermelonDataAccess.delete)
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
