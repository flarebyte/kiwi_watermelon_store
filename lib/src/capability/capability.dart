enum KiwiWatermelonDataAccess { read, write, delete }

class KWDataCapability {
  final String role;
  final String prefix;
  final KiwiWatermelonDataAccess access;

  KWDataCapability(
      {required this.role, required this.prefix, required this.access});

      static KWDataCapability read({required String role, required String prefix}){
        return KWDataCapability(role: role, prefix: prefix, access: KiwiWatermelonDataAccess.read);
      }

      static KWDataCapability write({required String role, required String prefix}){
        return KWDataCapability(role: role, prefix: prefix, access: KiwiWatermelonDataAccess.write);
      }

      static KWDataCapability delete({required String role, required String prefix}){
        return KWDataCapability(role: role, prefix: prefix, access: KiwiWatermelonDataAccess.delete);
      }
}

class KiwiWatermelonAutorisationManager {
  final List<KWDataCapability> capabilities;

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
