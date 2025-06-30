import '../data_store.dart';
import 'action_result.dart';
import 'base_action.dart';

class KiwiSetAction extends KiwiWatermelonAction {
  final String key;

  final num value;

  KiwiSetAction({required this.key, required this.value});

  @override
  KiwiWatermelonActionResult execute(KiwiWatermelonDataStore store) {
    store.set(key, value.toString());
    return new KiwiWatermelonActionResult();
  }
}
