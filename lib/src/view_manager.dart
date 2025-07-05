import '../kiwi_watermelon_store.dart';
import 'listener/handler.dart';

abstract class KiwiWatermelonBaseViewManager<T> {
  void registerView(KiwiWatermelonViewReducer<T> reducer,
      KiwiWatermelonOnViewUpdate onUpdate);
  BaseTypedDataStore<T> view();
}

class KiwiWatermelonViewManager<T> extends KiwiWatermelonBaseViewManager<T>{
  @override
  void registerView(KiwiWatermelonViewReducer<T> reducer, KiwiWatermelonOnViewUpdate onUpdate) {
    // TODO: implement registerView
  }

  @override
  BaseTypedDataStore<T> view() {
    // TODO: implement view
    throw UnimplementedError();
  }

}