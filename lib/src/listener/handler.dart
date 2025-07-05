import '../../kiwi_watermelon_store.dart';
import 'update_event.dart';

typedef ErrorHandler = void Function(String message);

typedef KiwiWatermelonViewReducer = void Function(BaseStringDataStore store, KiwiWatermelonUpdateEvent event);