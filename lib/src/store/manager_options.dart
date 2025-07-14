class KiwiWatermelonOptions {
  final List<String> prefixes;
  final List<String> userPrefixes;
  final Map<String, String> mapping;
  final bool Function(String) variableValidator;

  static bool arePrefixesIncluded(List<String> candidates, List<String> pool) {
    return Set.from(pool).containsAll(candidates);
  }

  KiwiWatermelonOptions(
      {required this.prefixes,
      required this.mapping,
      required this.userPrefixes,
      required this.variableValidator}) {
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

  /// Determines whether the given [text] represents a valid variable.
  ///
  /// The [text] must be in the format `<prefix>:<variableName>`, where the prefix is validated
  /// using [RhapsodySupportedPrefixes]. If the prefix is valid, the variable name (after the colon)
  /// is validated using [variableValidator].
  bool isVariable(String text) {
    if (!isPrefixSupported(text)) return false;
    final int colonIndex = text.indexOf(':');
    final String variablePart = text.substring(colonIndex + 1);
    if (variablePart.isEmpty) return false;
    return variableValidator(variablePart);
  }

  /// Return true if the value is an official enum
  bool isEnum(String value) {
    return mapping.keys.contains(value);
  }

  /// Returns the list of enums
  List<String> getEnums() {
    return mapping.keys.toList();
  }
}
