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

class KiwiWatermelonDynamicStore<T> extends BaseGetTypedDataStore<T> {
  final KiwiWatermelonStringTransformer<T> transformer;

  KiwiWatermelonDynamicStore({required this.transformer});

  @override
  get(String key) {
    final transformed = transformer(key);
    return transformed;
  }
}

class KiwiWatermelonMultiStore extends BaseGetTypedDataStore<String> {
  final Map<String, BaseGetTypedDataStore<String>> stores;
  late Map<String, String> mapping = {};

  KiwiWatermelonMultiStore({required this.stores}) {
    //a store may have multiple prefixes separated by coma
    for (var key in stores.keys) {
      final innerKeys = key.split(',');
      for (var innerKey in innerKeys) {
        mapping[innerKey] = key;
      }
    }
  }

  @override
  get(String key) {
    final [prefix, _] = key.split(':');

    final storeKey = mapping[prefix];
    if (storeKey == null) {
      return null;
    } else {
      final store = stores[storeKey];
      if (store == null) {
        return null;
      } else {
        return store.get(key);
      }
    }
  }
}
