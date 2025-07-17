enum KiwiWatermelonDataAccess { read, write, delete }

class KiwiWatermelonDataCapability {
  final String role;
  final String prefix;
  final KiwiWatermelonDataAccess access;

  KiwiWatermelonDataCapability(
      {required this.role, required this.prefix, required this.access});
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
    return canInvoke(key: key, access: KiwiWatermelonDataAccess.read, role: '');
  }

  bool canWrite({required String role, required String key}) {
    return canInvoke(
        key: key, access: KiwiWatermelonDataAccess.write, role: '');
  }

  bool canDelete({required String role, required String key}) {
    return canInvoke(
        key: key, access: KiwiWatermelonDataAccess.delete, role: '');
  }

  bool canReadAndWrite({required String role, required String key}) {
    return canRead(key: key, role: '') && canWrite(key: key, role: '');
  }

  bool canReadWriteDelete({required String role, required String key}) {
    return canRead(key: key, role: '') &&
        canWrite(key: key, role: '') &&
        canDelete(key: key, role: '');
  }
}
