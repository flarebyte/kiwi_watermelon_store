import 'listener/handler.dart';
import 'model/data_store.dart';
import 'model/data_store_options.dart';

/// A simple in-memory implementation of [BaseDataStore] using [Map].
class KiwiWatermelonDataStore implements BaseDataStore {
  final Map<String, String> _store = <String, String>{};
  final ErrorHandler handler;
  final DataStoreOptions options;

  KiwiWatermelonDataStore({required this.handler, required this.options});

  /// {@macro KiwiWatermelonDataStore.get}
  @override
  String? get(String key) {
    options.assertPrefix(key);
    return _store[key];
  }

  /// {@macro KiwiWatermelonDataStore.[]}
  @override
  String? operator [](String key) => get(key);

  /// {@macro KiwiWatermelonDataStore.set}
  @override
  void set(String key, String value) {
     options.assertPrefix(key);
    _store[key] = value;
  }

  /// {@macro KiwiWatermelonDataStore.remove}
  @override
  void remove(String key) {
    options.assertPrefix(key);
    _store.remove(key);
  }

  /// {@macro KiwiWatermelonDataStore.clear}
  @override
  void clear() {
    _store.clear();
  }

  /// {@macro KiwiWatermelonDataStore.addAll}
  @override
  void addAll(Map<String, String> other) {
    _store.addAll(other);
  }

  @override
  String toString() {
    return 'KiwiWatermelonDataStore{_store: $_store}';
  }

  toUnmodifiableMap() {
    return Map.unmodifiable(_store);
  }
}
