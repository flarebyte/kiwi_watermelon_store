enum KiwiWatermelonDataAccess {
  read, write, delete
}


class KiwiWatermelonDataCapability {
  final String prefix;
  final KiwiWatermelonDataAccess access;

  KiwiWatermelonDataCapability({required this.prefix, required this.access});

}

class KiwiWatermelonAutorisation {
final List<KiwiWatermelonDataCapability> capabilities;

  KiwiWatermelonAutorisation({required this.capabilities});

  bool canInvoke({required String key, required KiwiWatermelonDataAccess access}){
    return capabilities.any((capability)=>  key.startsWith(capability.prefix) && capability.access == access);
  }

  bool canRead({required String key}){
    return canInvoke(key: key, access: KiwiWatermelonDataAccess.read);
  }

  bool canWrite({required String key}){
    return canInvoke(key: key, access: KiwiWatermelonDataAccess.write);
  }

  bool canDelete({required String key}){
    return canInvoke(key: key, access: KiwiWatermelonDataAccess.delete);
  }

  bool canReadAndWrite({required String key}){
    return canRead(key: key) && canWrite(key: key);
  }

  bool canReadWriteDelete({required String key}){
    return canRead(key: key) && canWrite(key: key) && canDelete(key: key);
  }

}