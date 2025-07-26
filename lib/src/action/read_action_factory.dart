import '../select/get_action.dart';
import '../select/join_action.dart';
import '../select/select_base_action.dart';

class KiwiWatermelonReadActionFactory {
  /// Returns an action to read the value at [key].
  static KiwiGetStringAction get(String key) {
    return KiwiGetStringAction(key);
  }

  /// Returns an action join other actions.
  static KiwiJoinStringAction join(
      String separator, List<KiwiWatermelonSelectQuery<String>> actions) {
    return KiwiJoinStringAction(separator: separator, actions: actions);
  }
}
