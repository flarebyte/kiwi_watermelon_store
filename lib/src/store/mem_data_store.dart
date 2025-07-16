import 'data_store.dart';
import 'manager_options.dart';

/// A simple in-memory implementation of [BaseStringDataStore] using [Map].
class KiwiWatermelonDataStore implements BaseStringDataStore {
  final Map<String, String> _store = <String, String>{};
  final KiwiWatermelonOptions options;

  KiwiWatermelonDataStore({required this.options});

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

  Map<String, String> toUnmodifiableMap() {
    return Map.unmodifiable(_store);
  }

  @override
  Iterable<String> get keys {
    return _store.keys;
  }
}

/// A simple in-memory implementation of [BaseTypedDataStore] using [Map].
class KiwiWatermelonTypedDataStore<T> implements BaseTypedDataStore<T> {
  final Map<String, T> _store = <String, T>{};
  final KiwiWatermelonOptions options;

  KiwiWatermelonTypedDataStore({required this.options});

  /// {@macro KiwiWatermelonDataStore.get}
  @override
  T? get(String key) {
    options.assertPrefix(key);
    return _store[key];
  }

  /// {@macro KiwiWatermelonDataStore.[]}
  @override
  T? operator [](String key) => get(key);

  /// {@macro KiwiWatermelonDataStore.set}
  @override
  void set(String key, T value) {
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
  void addAll(Map<String, T> other) {
    _store.addAll(other);
  }

  @override
  String toString() {
    return 'KiwiWatermelonTypedDataStore{_store: $_store}';
  }

  Map<String, T> toUnmodifiableMap() {
    return Map.unmodifiable(_store);
  }

  @override
  Iterable<String> get keys {
    return _store.keys;
  }
}
