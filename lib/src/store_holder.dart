import '../kiwi_watermelon_store.dart';

class KiwiWatermelonReadStoreHolder {
  BaseGetTypedDataStore<String> _store;

  BaseGetTypedDataStore<String> get store => _store;

  set store(BaseGetTypedDataStore<String> value) {
    _store = value;
  }

  KiwiWatermelonReadStoreHolder({required BaseGetTypedDataStore<String> dataStore})
      : _store = dataStore;
}
