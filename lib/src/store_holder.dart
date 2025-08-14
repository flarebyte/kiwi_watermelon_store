import '../kiwi_watermelon_store.dart';

class KiwiWatermelonStoreHolder {
  BaseStringDataStore _store;

  BaseStringDataStore get store => _store;

  set store(BaseStringDataStore value) {
    _store = value;
  }

  KiwiWatermelonStoreHolder({required BaseStringDataStore dataStore})
      : _store = dataStore;

}
