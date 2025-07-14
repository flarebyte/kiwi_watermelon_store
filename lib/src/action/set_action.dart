import '../../kiwi_watermelon_store.dart';
import '../language/tokeniser_helper.dart';
import 'action_patch.dart';
import 'action_result.dart';
import 'base_action.dart';

class KiwiSetStringAction extends KiwiWatermelonAction {
  final String key;

  final String value;

  KiwiSetStringAction(this.key, this.value);

  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    return new KiwiWatermelonActionResult(
        patch: KiwiWatermelonPatch(updates: {key: value}, deletions: []));
  }
}

class KiwiSetIntegerAction extends KiwiSetStringAction {
  KiwiSetIntegerAction(String key, int value) : super(key, value.toString());
}

class KiwiSetFloatAction extends KiwiSetStringAction {
  KiwiSetFloatAction(String key, double value) : super(key, value.toString());
}

class KiwiSetUuidAction extends KiwiSetStringAction {
  KiwiSetUuidAction(String key, String value, {bool validate = true})
      : super(key, value) {
    if (!validate) {
      return;
    }
    if (!isUuid(value)) {
      throw Exception("The value should be an UUID but is $value");
    }
  }
}
