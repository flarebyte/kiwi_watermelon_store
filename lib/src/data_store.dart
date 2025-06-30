
import 'model/data_store.dart';

/// A simple in-memory implementation of [BaseDataStore] using [Map].
class KiwiWatermelonDataStore implements BaseDataStore {
  final Map<String, String> _store = <String, String>{};

  /// {@macro KiwiWatermelonDataStore.get}
  @override
  String? get(String key) => _store[key];

  /// {@macro KiwiWatermelonDataStore.[]}
  @override
  String? operator [](String key) => _store[key];

  /// {@macro KiwiWatermelonDataStore.set}
  @override
  void set(String key, String value) {
    _store[key] = value;
  }

  /// {@macro KiwiWatermelonDataStore.remove}
  @override
  void remove(String key) {
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
    return 'RhapsodyDataStore{_store: $_store}';
  }
}