/// Represents a key-value data store that supports prefix validation
/// and optional typed value decoding.
abstract class BaseDataStore {
  /// Retrieves the string value associated with [key], or `null` if not found.
  String? get(String key);

  ///The value for the given key, or null if key is not in the map.
  String? operator [](String key);

  /// Associates the [value] with the given [key], replacing any existing value.
  void set(String key, String value);

  /// Removes the entry associated with [key], if it exists.
  void remove(String key);

  /// Clear the data store
  void clear();

  /// Add multiple values at once
  void addAll(Map<String, String> other);
}

