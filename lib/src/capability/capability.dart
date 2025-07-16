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

  canInvoke({required String key, required KiwiWatermelonDataAccess access}){
    capabilities.any((capability)=>  key.startsWith(capability.prefix) && capability.access == access);
  }

}