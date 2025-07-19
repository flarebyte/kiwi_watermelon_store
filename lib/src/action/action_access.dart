import '../autorisation/autorisation_manager.dart';
import '../autorisation/capability.dart';

class KiwiWatermelonActionAccess {
  late KiwiWatermelonAutorisationManager autorisation;

  final List<KiwiWatermelonDataCapability> capabilities;

  KiwiWatermelonActionAccess({required this.capabilities}) {
    autorisation =
        KiwiWatermelonAutorisationManager(capabilities: capabilities);
  }

  bool incr(String key, {String role = 'none'}) {
    return autorisation.canReadAndWrite(key: key, role: role);
  }
}
