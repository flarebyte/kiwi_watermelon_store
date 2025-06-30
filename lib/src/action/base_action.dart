import '../data_store.dart';
import 'action_result.dart';

abstract class KiwiWatermelonAction {

  KiwiWatermelonActionResult execute(KiwiWatermelonDataStore store);

}