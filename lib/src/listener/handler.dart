import '../../kiwi_watermelon_store.dart';
import 'update_event.dart';

typedef KiwiWatermelonErrorHandler = void Function(String message);

typedef KiwiWatermelonViewReducer<T> = void Function(BaseTypedDataStore<T> store, KiwiWatermelonUpdateEvent event);

typedef KiwiWatermelonOnViewUpdate = void Function(KiwiWatermelonUpdateEvent event);
