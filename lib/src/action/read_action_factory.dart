import '../select/get_action.dart';

class KiwiWatermelonReadActionFactory {

   /// Returns an action to read the value at [key].
  static KiwiGetStringAction get(String key) {
    return KiwiGetStringAction(key);
  }
}