import '../../kiwi_watermelon_store.dart';
import 'select_action_result.dart';

abstract class KiwiWatermelonSelectQuery<T> {
  KiwiWatermelonSelectActionResult<T> execute(BaseGetTypedDataStore<T> store);
}
