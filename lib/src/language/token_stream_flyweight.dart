import 'token.dart';
import 'token_stream.dart';
import 'tokeniser.dart';

/// Provides flyweight static methods for common token consumption and peeking
/// operations on [KiwiWatermelonTokenStream].
///
/// This class centralizes logic for parsing token types and operator keywords
/// to ensure consistency and reduce duplication across the codebase.
///
/// All methods are static and stateless, making them suitable for reuse.
class KiwiWatermelonTokenStreamFlyweight {
  /// Consumes and returns the current token if it is an `identifier`.
  ///
  /// Throws a [SemanticException] if the current token is not an identifier.
  static KiwiWatermelonToken consumeIdentifier(KiwiWatermelonTokenStream tokens,
      {String? contextual}) {
    return tokens.consumeAndValidate(TokenTypes.identifier,
        contextual: contextual);
  }

  /// Checks if the next token is a comma (`comma`) without consuming it.
  ///
  /// Returns `true` if the next token is a comma; otherwise, `false`.
  static bool peekIsComma(KiwiWatermelonTokenStream tokens) {
    return tokens.peekMatchesType(TokenTypes.comma);
  }

  /// Consumes the next token if it is a comma (`comma`).
  ///
  /// Throws a [SemanticException] if the next token is not a comma.
  static void consumeComma(KiwiWatermelonTokenStream tokens,
      {String? contextual}) {
    tokens.consumeAndValidate(TokenTypes.comma, contextual: contextual);
  }

  /// Checks if the next token is a semicolon (`semicolon`) without consuming it.
  ///
  /// Returns `true` if the next token is a semicolon; otherwise, `false`.
  static bool peekIsSemicolon(KiwiWatermelonTokenStream tokens) {
    return tokens.peekMatchesType(TokenTypes.semicolon);
  }

  /// Consumes the next token if it is a semicolon (`semicolon`).
  ///
  /// Throws a [SemanticException] if the next token is not a semicolon.
  static void consumeSemicolon(KiwiWatermelonTokenStream tokens,
      {String? contextual}) {
    tokens.consumeAndValidate(TokenTypes.semicolon, contextual: contextual);
  }

  /// Checks if the next token is a colon (`colon`) without consuming it.
  ///
  /// Returns `true` if the next token is a colon; otherwise, `false`.
  static bool peekIsColon(KiwiWatermelonTokenStream tokens) {
    return tokens.peekMatchesType(TokenTypes.colon);
  }

  /// Consumes the next token if it is a colon (`colon`).
  ///
  /// Throws a [SemanticException] if the next token is not a colon.
  static void consumeColon(KiwiWatermelonTokenStream tokens,
      {String? contextual}) {
    tokens.consumeAndValidate(TokenTypes.colon, contextual: contextual);
  }

  /// Checks if the current token is a comma (`comma`).
  ///
  /// Returns `true` if the current token is a comma; otherwise, `false`.
  static bool isComma(KiwiWatermelonTokenStream tokens) {
    return tokens.matchType(TokenTypes.comma);
  }

  /// Checks if the current token is a semicolon (`semicolon`).
  ///
  /// Returns `true` if the current token is a semicolon; otherwise, `false`.
  static bool isSemicolon(KiwiWatermelonTokenStream tokens) {
    return tokens.matchType(TokenTypes.semicolon);
  }

  /// Checks if the current token is a colon (`colon`).
  ///
  /// Returns `true` if the current token is a colon; otherwise, `false`.
  static bool isColon(KiwiWatermelonTokenStream tokens) {
    return tokens.matchType(TokenTypes.colon);
  }

  /// Checks if the current token is an identifier with specific [text]
  static bool peekIsAnyKeyword(
      KiwiWatermelonTokenStream tokens, List<String> keywords) {
    final isIdentifier = tokens.peekMatchesType(TokenTypes.identifier);
    final hasKeyword =
        keywords.any((keyword) => tokens.peekMatchesText(keyword));
    return isIdentifier && hasKeyword;
  }

}
