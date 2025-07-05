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
