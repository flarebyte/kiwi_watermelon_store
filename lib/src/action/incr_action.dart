import '../../kiwi_watermelon_store.dart';
import 'action_patch.dart';
import 'action_result.dart';
import 'base_action.dart';

class KiwiIncrAction extends KiwiWatermelonAction {
  final String key;
  KiwiIncrAction({required this.key});

  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final previous = store.get(key) ?? "0";
    final previousInt = int.tryParse(previous);
    if (previousInt == null) {
      return new KiwiWatermelonActionResult(
          error: KiwiWatermelonActionError(
              message: 'Existing value should be an integer', keys: [key]));
    } else {
      return new KiwiWatermelonActionResult(
          patch: KiwiWatermelonPatch(
              updates: {key: (previousInt + 1).toString()}, deletions: []));
    }
  }
}
