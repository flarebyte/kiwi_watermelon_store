import '../../kiwi_watermelon_store.dart';

class KiwiWatermelonReadStore<T> extends BaseReadTypedDataStore<T> {
  final Map<String, T> _store = <String, T>{};

  KiwiWatermelonReadStore();

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

typedef KiwiWatermelonStringTransformer<T> = T? Function(String code);

class KiwiWatermelonLazyReadStore<T> extends BaseGetTypedDataStore<T> {
  final Map<String, T> _store = <String, T>{};
  final KiwiWatermelonStringTransformer<T> transformer;

KiwiWatermelonLazyReadStore({required this.transformer});
  @override
  get(String code) {
    final existing = _store[code];
    if (existing != null) {
      return existing;
    }

    final transformed = transformer(code);
    if (transformed != null) {
      _store[code] = transformed;
    }

    return transformed;
  }

}

class KiwiWatermelonDynamicSore<T> extends BaseGetTypedDataStore<T> {
  final KiwiWatermelonStringTransformer<T> transformer;

  KiwiWatermelonDynamicSore({required this.transformer});

  @override
  get(String key) {
    final transformed = transformer(key);
    return transformed;
  }

}
