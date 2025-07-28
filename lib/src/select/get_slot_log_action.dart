import 'package:kiwi_watermelon_store/src/select/select_action_result.dart';

import 'package:kiwi_watermelon_store/src/store/data_store.dart';

import 'select_base_action.dart';

/// get a string
/// GETSLOTINDEXLOG <value> <min_value> <max_value> <num_slots> [BASE <log_base>]
class KiwiGetSlotIndexLogAction extends KiwiWatermelonSelectQuery<String> {
  final String key;
  final int minValue;
  final int maxValue;
  final int numSlots;
  KiwiGetSlotIndexLogAction(this.key, this.minValue, this.maxValue, this.numSlots);

  @override
  KiwiWatermelonSelectActionResult<String> execute(
      BaseGetTypedDataStore<String> store) {
        // TODO
    return KiwiWatermelonSelectActionResult(value: store.get(key));
  }
}
