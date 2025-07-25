import '../kiwi_watermelon_store.dart';
import 'select/select_action_result.dart';
import 'select/select_base_action.dart';

class KiwiWatermelonStringStoreReader {

  final BaseReadTypedDataStore<String> stringStore;
  KiwiWatermelonStringStoreReader({required this.stringStore});

   KiwiWatermelonSelectActionResult<String> queryString(KiwiWatermelonSelectQuery<String> query){
      return query.execute(stringStore);
   }

}

class KiwiWatermelonAnyStoreReader<T> {

  final BaseReadTypedDataStore<String> stringStore;
  final BaseReadTypedDataStore<T> anyStore;
  KiwiWatermelonAnyStoreReader({required this.stringStore, required this.anyStore});

   KiwiWatermelonSelectActionResult<T> queryAny(KiwiWatermelonSelectQuery<T> query){
      return query.execute(anyStore);
   }

}