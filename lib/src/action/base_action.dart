import '../../kiwi_watermelon_store.dart';
import 'action_result.dart';

abstract class KiwiWatermelonAction {
  KiwiWatermelonActionResult execute(BaseStringDataStore store);
}
