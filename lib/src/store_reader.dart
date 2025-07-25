import '../kiwi_watermelon_store.dart';
import 'select/select_action_result.dart';
import 'select/select_base_action.dart';
import 'store/manager_options.dart';

class KiwiWatermelonStringStoreReader {

  final KiwiWatermelonOptions options;
  KiwiWatermelonStringStoreReader({required this.options});

   KiwiWatermelonSelectActionResult<String> queryString(KiwiWatermelonSelectQuery<String> query, BaseReadTypedDataStore<String> store){
      return query.execute(store);
   }

}