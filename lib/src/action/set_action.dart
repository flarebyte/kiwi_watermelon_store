import '../../kiwi_watermelon_store.dart';
import 'action_patch.dart';
import 'action_result.dart';
import 'base_action.dart';

class KiwiSetAction extends KiwiWatermelonAction {
  final String key;

  final num value;

  KiwiSetAction({required this.key, required this.value});

  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    return new KiwiWatermelonActionResult(
        patch:
            KiwiWatermelonPatch(updates: {key: value.toString()}, deletions: []));
  }
}
