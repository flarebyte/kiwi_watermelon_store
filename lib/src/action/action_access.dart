import '../capability/capability.dart';

class KiwiWatermelonActionAccess {
final KiwiWatermelonAutorisationManager autorisation;

  KiwiWatermelonActionAccess({required this.autorisation});

  bool incr(String key) {
   return autorisation.canReadAndWrite(key: key, role: 'temp');
  }

}