import '../kiwi_watermelon_store.dart';
import 'select/select_action_result.dart';
import 'select/select_base_action.dart';
import 'store/read_store.dart';

class KiwiWatermelonStringStoreReader {
  final KiwiWatermelonLazyReadStore<KiwiWatermelonSelectQuery<String>>
      lazyQueryStore;
  KiwiWatermelonStringStoreReader({required this.lazyQueryStore});

  KiwiWatermelonSelectActionResult<String> queryString(
      String query, BaseGetTypedDataStore<String> store) {
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

class KiwiWatermelonTwoHopsAnyStoreReader<T> {
  final KiwiWatermelonLazyReadStore<KiwiWatermelonSelectQuery<String>>
      lazyQueryStore;
  final BaseReadTypedDataStore<T> anyStore;
  KiwiWatermelonTwoHopsAnyStoreReader(
      {required this.lazyQueryStore, required this.anyStore});

  KiwiWatermelonSelectActionResult<T> queryAny(
      String query, BaseGetTypedDataStore<String> stringStore) {
    final KiwiWatermelonSelectQuery<String>? queryObj =
        lazyQueryStore.get(query);
    if (queryObj == null) {
      return KiwiWatermelonSelectActionResult(
          error: KiwiWatermelonSelectActionError(
              message: 'Invalid read query', code: query));
    } else {
      final mainKeyResult = queryObj.execute(stringStore);
      if (mainKeyResult.error != null) {
        return KiwiWatermelonSelectActionResult(error: mainKeyResult.error);
      }

      final mainKey = mainKeyResult.value;
      if (mainKey == null || mainKey.isEmpty) {
        return KiwiWatermelonSelectActionResult(value: null);
      } else {
        final secondHopValue = anyStore.get(mainKey);
        return KiwiWatermelonSelectActionResult(value: secondHopValue);
      }
    }
  }
}
