import '../../kiwi_watermelon_store.dart';

class KiwiWatermelonRead<T> extends BaseReadTypedDataStore<T> {
  final Map<String, T> _store = <String, T>{};
  @override
  operator [](String key) {
    return _store[key];
  }

  @override
  bool containsKey(String key) {
    return _store.containsKey(key);
  }

  @override
  get(String key) {
    return _store[key];
  }

  @override
  Iterable<String> get keys {
    return _store.keys;
  }

  @override
  Map<String, T> toUnmodifiableMap() {
    return Map.unmodifiable(_store);
  }

  void addAll(Map<String, T> other) {
    _store.addAll(other);
  }
}
