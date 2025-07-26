import '../kiwi_watermelon_store.dart';
import 'select/select_action_result.dart';
import 'select/select_base_action.dart';
import 'store/read_store.dart';

class KiwiWatermelonStringStoreReader {
  final KiwiWatermelonLazyReadStore<KiwiWatermelonSelectQuery<String>>
      lazyQueryStore;
  KiwiWatermelonStringStoreReader({required this.lazyQueryStore});

  KiwiWatermelonSelectActionResult<String> queryString(
      String query, BaseReadTypedDataStore<String> store) {
    final KiwiWatermelonSelectQuery<String>? queryObj =
        lazyQueryStore.get(query);
    if (queryObj == null) {
      return KiwiWatermelonSelectActionResult(
          error: KiwiWatermelonSelectActionError(
              message: 'Invalid read query', code: query));
    } else {
      return queryObj.execute(store);
    }
  }
}

class KiwiWatermelonAnyStoreReader<T> {
  final BaseReadTypedDataStore<String> stringStore;
  final BaseReadTypedDataStore<T> anyStore;
  KiwiWatermelonAnyStoreReader(
      {required this.stringStore, required this.anyStore});

  KiwiWatermelonSelectActionResult<T> queryAny(
      KiwiWatermelonSelectQuery<T> query) {
    return query.execute(anyStore);
  }
}
