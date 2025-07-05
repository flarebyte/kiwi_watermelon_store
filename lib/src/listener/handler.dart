import '../../kiwi_watermelon_store.dart';
import '../action/action_patch.dart';

typedef KiwiWatermelonErrorHandler = void Function(String message);

typedef KiwiWatermelonViewReducer<T> = void Function(BaseTypedDataStore<T> store, KiwiWatermelonPatch patch);

typedef KiwiWatermelonOnViewUpdate = void Function(KiwiWatermelonPatch patch);
