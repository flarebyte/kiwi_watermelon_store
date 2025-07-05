import '../kiwi_watermelon_store.dart';
import 'store/manager_options.dart';
import 'store/mem_data_store.dart';

abstract class KiwiWatermelonBaseFactory {
  BaseTypedDataStore<T> createTypedDataStore<T>(
      KiwiWatermelonOptions options);
  BaseStringDataStore createStringDataStore(
      KiwiWatermelonOptions options);
}

class KiwiWatermelonDefaultFactory extends KiwiWatermelonBaseFactory {
  @override
  BaseStringDataStore createStringDataStore(
      KiwiWatermelonOptions options) {
    return KiwiWatermelonDataStore(options: options);
  }

  @override
  BaseTypedDataStore<T> createTypedDataStore<T>(
      KiwiWatermelonOptions options) {
    return KiwiWatermelonTypedDataStore(options: options);
  }
}
