import 'package:kiwi_watermelon_store/src/select/select_action_result.dart';

import 'package:kiwi_watermelon_store/src/store/data_store.dart';

import 'select_base_action.dart';

/// join multiple result
class KiwiJoinStringAction extends KiwiWatermelonSelectQuery<String> {
  final String separator;
  final List<KiwiWatermelonSelectQuery<String>> actions;
  KiwiJoinStringAction({required this.separator, required this.actions});

  @override
  KiwiWatermelonSelectActionResult<String> execute(
      BaseGetTypedDataStore<String> store) {
    final stringResults = actions.map((action) => action.execute(store));
    final errors = stringResults.where((result) => result.error != null);
    if (errors.isNotEmpty) {
      final firstError = errors.first.error;
      return KiwiWatermelonSelectActionResult(error: firstError);
    }
    final strings =
        stringResults.map((result) => result.value).whereType<String>();
    return KiwiWatermelonSelectActionResult(value: strings.join(separator));
  }
}
