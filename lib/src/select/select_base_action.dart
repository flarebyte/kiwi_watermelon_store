import '../../kiwi_watermelon_store.dart';
import 'select_action_result.dart';

abstract class KiwiWatermelonSelectAction<T> {
  KiwiWatermelonSelectActionResult<T> execute(BaseReadTypedDataStore<T> store);
}
