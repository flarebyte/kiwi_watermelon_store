import 'listener/handler.dart';
import 'model/data_store.dart';
import 'model/data_store_options.dart';

/// A simple in-memory implementation of [BaseDataStore] using [Map].
class KiwiWatermelonDataStore implements BaseDataStore {
  final Map<String, String> _store = <String, String>{};
  final ErrorHandler errorHandler;
  final DataStoreOptions options;

  KiwiWatermelonDataStore({required this.errorHandler, required this.options});

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

//      `set scope:name to value`: Sets the variable to a value.
// -   `inc scope:name amount`: Increments numeric value by an amount.
// -   `dec scope:name amount`: Decrements numeric value by an amount.
// -   `clear scope:name`: Removes the variable from the store.
// -   `list append scope:name value`: Appends a value to a list variable.
// -   `set scope:name value`: Appends a value to a set variable.

  void setNumber(String key, num value) {
    set(key, value.toString());
  }

  void incNumber(String key, num value) {
    final previous = get(key);
    if (previous == null) {
      set(key, value.toString());
    } else {
      final previousNum = num.tryParse(previous);
      if (previousNum == null) {
        errorHandler('The value for the existing key is not a number:' + key);
      } else {
        final newValue = previousNum + value;
        set(key, newValue.toString());
      }
    }
  }
}
