import 'token.dart';

/// Thrown when the semantic analyser encounters an unexpected token.
class KiwiWatermelonSemanticException implements Exception {
  final String message;
  final KiwiWatermelonToken token;
  KiwiWatermelonSemanticException(this.message, this.token);

  @override
  String toString() =>
      "SemanticException: $message at token '${token.text}' and index ${token.startIndex}";
}

/// Thrown when the semantic analyser encounters an unexpected token.
class KiwiWatermelonAccessException implements KiwiWatermelonSemanticException {
  final String role;
  final String command;
  final String key;
  final List<String> otherKeys;
  final KiwiWatermelonToken token;
  KiwiWatermelonAccessException(
      {required this.role,
      required this.command,
      required this.key,
      required this.otherKeys,
      required this.token});

  @override
  String toString() {
    final possibleKeys = [key, ...otherKeys].join(' ');
    return "Access denied for $role attempting to $command with $possibleKeys at token '${token.text}' and index ${token.startIndex}";
  }

  String get message {
    final possibleKeys = [key, ...otherKeys].join(' ');
    return "Access denied for $role attempting to $command with $possibleKeys";
  }
}
