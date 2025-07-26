/// Read only datastore
abstract class BaseGetTypedDataStore<T> {
  /// Retrieves the string value associated with [key], or `null` if not found.
  T? get(String key);

  ///The value for the given key, or null if key is not in the map.
  T? operator [](String key) {
    return get(key);
  }
}

/// Read only datastore
abstract class BaseReadTypedDataStore<T> extends BaseGetTypedDataStore<T> {
  /// Convert to Unmodifiable Map
  Map<String, T> toUnmodifiableMap();

  Iterable<String> get keys;

  bool containsKey(String key);
}

/// Represents a key-value data store that supports prefix validation
/// and optional typed value decoding.
abstract class BaseTypedDataStore<T> extends BaseReadTypedDataStore<T> {
  /// Associates the [value] with the given [key], replacing any existing value.
  void set(String key, T value);

  /// Removes the entry associated with [key], if it exists.
  void remove(String key);

  /// Clear the data store
  void clear();

  /// Add multiple values at once
  void addAll(Map<String, T> other);
}

/// Represents a key-value data store that supports prefix validation
/// and optional typed value decoding.
abstract class BaseStringDataStore extends BaseTypedDataStore<String> {}
