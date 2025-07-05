import '../kiwi_watermelon_store.dart';
import './store/mem_data_store.dart';
import 'listener/handler.dart';

abstract class KiwiWatermelonBaseViewManager<T> {
  BaseTypedDataStore<T> view();
}

class KiwiWatermelonViewManager<T> extends KiwiWatermelonBaseViewManager<T> {
  final KiwiWatermelonTypedDataStore<T> store;
  final KiwiWatermelonViewReducer<T> reducer;
  final KiwiWatermelonOnViewUpdate onUpdate;

  KiwiWatermelonViewManager(
      {required this.store, required this.onUpdate, required this.reducer});

  @override
  BaseTypedDataStore<T> view() {
    return store;
  }
}
