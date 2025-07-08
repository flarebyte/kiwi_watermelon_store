import 'package:kiwi_watermelon_store/src/action/action_patch.dart';

import '../kiwi_watermelon_store.dart';
import 'factory.dart';
import 'listener/handler.dart';
import 'store/manager_options.dart';

abstract class KiwiWatermelonBaseViewManager<T> {
  BaseTypedDataStore<T> view();
  void applyPatch(KiwiWatermelonPatch patch);
}

class KiwiWatermelonViewManager<T> extends KiwiWatermelonBaseViewManager<T> {
  final KiwiWatermelonOptions options;
  final KiwiWatermelonBaseFactory factory;
  late BaseTypedDataStore<T> storeView;
  final KiwiWatermelonViewReducer<T> reducer;
  final KiwiWatermelonOnViewUpdate onUpdate;

  KiwiWatermelonViewManager(
      {required this.options,
      required this.factory,
      required this.storeView,
      required this.onUpdate,
      required this.reducer}) {
    storeView = factory.createTypedDataStore<T>(options: options);
  }

  @override
  BaseTypedDataStore<T> view() {
    return storeView;
  }

  @override
  void applyPatch(KiwiWatermelonPatch patch) {
    final hasChanged = reducer(storeView, patch);
    if (hasChanged) {
      onUpdate(patch);
    }
  }
}
