import 'package:kiwi_watermelon_store/src/language/tokeniser_helper.dart';
import 'package:kiwi_watermelon_store/src/select/select_action_result.dart';

import 'package:kiwi_watermelon_store/src/store/data_store.dart';

import 'select_base_action.dart';

/// get a the plurality of a value: zero, one or n
class KiwiGetPluralityStringAction extends KiwiWatermelonSelectQuery<String> {
  final String key;
  KiwiGetPluralityStringAction(this.key);

  @override
  KiwiWatermelonSelectActionResult<String> execute(
      BaseGetTypedDataStore<String> store) {
    final value = store.get(key);
    if (value == null || value.isEmpty) {
      return KiwiWatermelonSelectActionResult(value: _toPlurality(0));
    } else if (isInteger(value)) {
      return KiwiWatermelonSelectActionResult(
          value: _toPlurality(int.tryParse(value) ?? 0));
    } else if (value.contains(',')) {
      return KiwiWatermelonSelectActionResult(
          value: _toPlurality(value.split(',').length));
    } else {
      return KiwiWatermelonSelectActionResult(value: _toPlurality(0));
    }
  }

  _toPlurality(int value) {
    if (value <= 0) {
      return "zero";
    } else if (value == 1) {
      return "one";
    } else {
      return "n";
    }
  }
}
