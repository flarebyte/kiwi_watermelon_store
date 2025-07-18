import '../capability/capability.dart';

class KiwiWatermelonActionAccess {
final KiwiWatermelonAutorisationManager autorisation;

  KiwiWatermelonActionAccess({required this.autorisation});

  bool incr(String key, {String role = 'none'}) {
   return autorisation.canReadAndWrite(key: key, role: role);
  }

}