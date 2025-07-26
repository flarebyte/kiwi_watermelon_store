import 'package:kiwi_watermelon_store/src/select/select_action_result.dart';

import 'package:kiwi_watermelon_store/src/store/data_store.dart';

import 'select_base_action.dart';

/// get a string
class KiwiGetStringAction extends KiwiWatermelonSelectQuery<String> {
  final String key;
  KiwiGetStringAction({required this.key});

  @override
  KiwiWatermelonSelectActionResult<String> execute(
      BaseGetTypedDataStore<String> store) {
    return KiwiWatermelonSelectActionResult(value: store.get(key));
  }
}
