class DataStoreOptions {
  final List<String> prefixes;
  final Map<String, String> mapping;

  DataStoreOptions({required this.prefixes, required this.mapping});

  /// Checks if the given reference starts with any of the supported prefixes.
  ///
  /// **Parameters:**
  /// - `ref`: The reference to validate.
  ///
  /// **Returns:**
  /// - `true` if the reference starts with any supported prefix; otherwise, `false`.
  bool isPrefixSupported(String ref) {
    return prefixes.any((prefix) => ref.startsWith("$prefix:"));
  }

  /// Ensures the given reference starts with a supported prefix.
  ///
  /// **Parameters:**
  /// - `ref`: The reference to validate.
  ///
  /// **Throws:**
  /// - `Exception` if the reference does not start with a supported prefix.
  void assertPrefix(String ref) {
    if (!isPrefixSupported(ref)) {
      final prefixesDisplay = prefixes.map((prefix) => "$prefix:").join(", ");
      throw Exception("The ref $ref should start with any of $prefixesDisplay");
    }
  }
}
