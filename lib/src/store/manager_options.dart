class KiwiWatermelonOptions {
  final List<String> prefixes;
  final List<String> userPrefixes;
  final Map<String, String> mapping;

  static bool arePrefixesIncluded(List<String> candidates, List<String> pool) {
    return Set.from(pool).containsAll(candidates);
  }

  KiwiWatermelonOptions(
      {required this.prefixes,
      required this.mapping,
      required this.userPrefixes}) {
    if (!arePrefixesIncluded(userPrefixes, prefixes)) {
      throw Exception(
          "All user prefixes [$userPrefixes] should be included in all prefixes");
    }
  }

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

  bool isUserPrefix(String ref) {
    return userPrefixes.any((prefix) => ref.startsWith("$prefix:"));
  }
}
