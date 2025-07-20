import '../store/manager_options.dart';
import 'literal.dart';
import 'semantic_exception.dart';
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
class KiwiTokenStreamFlyweight {
  /// Consumes and returns the current token if it is an `identifier`.
  ///
  /// Throws a [KiwiWatermelonSemanticException] if the current token is not an identifier.
  static KiwiWatermelonToken consumeIdentifier(KiwiWatermelonTokenStream tokens,
      {String? contextual}) {
    return tokens.consumeAndValidate(TokenTypes.identifier,
        contextual: contextual);
  }

  /// Checks if the next token is a semicolon (`semicolon`) without consuming it.
  ///
  /// Returns `true` if the next token is a semicolon; otherwise, `false`.
  static bool peekIsSemicolon(KiwiWatermelonTokenStream tokens) {
    return tokens.peekMatchesType(TokenTypes.semicolon);
  }

  /// Consumes the next token if it is a semicolon (`semicolon`).
  ///
  /// Throws a [KiwiWatermelonSemanticException] if the next token is not a semicolon.
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
  /// Throws a [KiwiWatermelonSemanticException] if the next token is not a colon.
  static void consumeColon(KiwiWatermelonTokenStream tokens,
      {String? contextual}) {
    tokens.consumeAndValidate(TokenTypes.colon, contextual: contextual);
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
  static bool isAnyKeyword(
      KiwiWatermelonTokenStream tokens, List<String> keywords) {
    final isIdentifier = tokens.matchType(TokenTypes.identifier);
    final hasKeyword = keywords.any((keyword) => tokens.matchText(keyword));
    return isIdentifier && hasKeyword;
  }

  /// Checks if the next token is an identifier with specific [text]
  static bool peekIsAnyKeyword(
      KiwiWatermelonTokenStream tokens, List<String> keywords,
      {int lookahead = 1}) {
    final isIdentifier =
        tokens.peekMatchesType(TokenTypes.identifier, lookahead: lookahead);
    final hasKeyword = keywords.any(
        (keyword) => tokens.peekMatchesText(keyword, lookahead: lookahead));
    return isIdentifier && hasKeyword;
  }

  /// Composite a composite variable (ex: env:flag:red)
  static String consumeCompositeVariable(KiwiWatermelonTokenStream tokens,
      {required KiwiWatermelonOptions options}) {
    final prefixToken =
        consumeIdentifier(tokens, contextual: "scope of variable");
    consumeColon(tokens, contextual: "variable");
    final varToken = consumeIdentifier(tokens, contextual: "variable name");

    var maxSegments = 16;
    var compositeName = "";
    while (maxSegments > 0 && isColon(tokens)) {
      maxSegments = maxSegments - 1;
      consumeColon(tokens, contextual: "composite variable");
      final partOfName =
          consumeIdentifier(tokens, contextual: "composite variable name").text;
      compositeName = "$compositeName:$partOfName";
    }
    final varName = "${prefixToken.text}:${varToken.text}$compositeName";

    if (maxSegments <= 0) {
      throw KiwiWatermelonSemanticException(
          "Expecting a valid composite variable format with just a few colons but got $varName",
          prefixToken);
    }

    final isSupportedVar = options.isVariable(varName);
    if (!isSupportedVar) {
      throw KiwiWatermelonSemanticException(
          "Expecting a valid variable format with a scope but got $varName",
          prefixToken);
    }

    return varName;
  }

  /// Checks if the current token is number).
  ///
  /// Returns `true` if the current token is a number; otherwise, `false`.
  static bool isNumber(KiwiWatermelonTokenStream tokens) {
    return tokens.matchType(TokenTypes.number);
  }

  /// Consume and return an integer
  static int consumeInteger(KiwiWatermelonTokenStream tokens,
      {String? contextual}) {
    final intToken =
        tokens.consumeAndValidate(TokenTypes.number, contextual: contextual);
    final value = int.tryParse(intToken.text);
    if (value == null) {
      throw KiwiWatermelonSemanticException(
          "The sequence of digits is not a valid integer", intToken);
    } else {
      return value;
    }
  }

  /// Checks if the current token is float.
  ///
  /// Returns `true` if the current token is a float; otherwise, `false`.
  static bool isFloat(KiwiWatermelonTokenStream tokens) {
    return tokens.matchType(TokenTypes.float);
  }

  /// Consume and return a float or double
  static double consumeDouble(KiwiWatermelonTokenStream tokens,
      {String? contextual}) {
    final floatToken =
        tokens.consumeAndValidate(TokenTypes.float, contextual: contextual);
    final value = double.tryParse(floatToken.text);
    if (value == null) {
      throw KiwiWatermelonSemanticException(
          "The sequence of digits is not a valid float or double", floatToken);
    } else {
      return value;
    }
  }

  /// Checks if the current token is a UUID
  ///
  /// Returns `true` if the current token is a UUID; otherwise, `false`.
  static bool isUuid(KiwiWatermelonTokenStream tokens) {
    return tokens.matchType(TokenTypes.uuid);
  }

  /// Consume and return a UUID
  static String consumeUuid(KiwiWatermelonTokenStream tokens,
      {String? contextual}) {
    final uuidToken =
        tokens.consumeAndValidate(TokenTypes.uuid, contextual: contextual);
    return uuidToken.text;
  }

  /// Checks if the current token is int, float, uuid or enum.
  ///
  /// Returns `true` if the current token is a int, float, uuid or enum; otherwise, `false`.
  static bool isStructuredLiteral(
    KiwiWatermelonTokenStream stream, {
    required List<String> enumKeywords,
  }) {
    return isNumber(stream) ||
        isFloat(stream) ||
        isUuid(stream) ||
        isAnyKeyword(stream, enumKeywords);
  }

  /// Consumes and classifies a literal token (int, float, UUID, or enum keyword).
  ///
  /// Returns a [ParsedLiteral] subtype.
  /// Throws [KiwiWatermelonSemanticException] if no supported literal is found.
  static ParsedLiteral consumeStructuredLiteral(
    KiwiWatermelonTokenStream stream, {
    required List<String> enumKeywords,
  }) {
    if (isNumber(stream)) {
      final value = consumeInteger(stream);
      return ParsedInteger(value);
    }

    if (isFloat(stream)) {
      final value = consumeDouble(stream);
      return ParsedFloat(value);
    }

    if (isUuid(stream)) {
      final value = consumeUuid(stream);
      return ParsedUuid(value);
    }

    if (isAnyKeyword(stream, enumKeywords)) {
      final value = consumeIdentifier(stream).text;
      return ParsedEnum(value);
    }

    throw KiwiWatermelonSemanticException(
      'Expected int, float, UUID, or enum',
      stream.current,
    );
  }

  /// Consumes and parses all remaining space-separated literal arguments in the stream.
  ///
  /// Each argument must be a valid int, float, UUID, or enum keyword (from [enumKeywords]).
  ///
  /// Throws [KiwiWatermelonSemanticException] on first invalid token.
  static List<ParsedLiteral> consumeStructuredLiterals(
    KiwiWatermelonTokenStream stream, {
    required List<String> enumKeywords,
  }) {
    final result = <ParsedLiteral>[];

    while (isStructuredLiteral(stream, enumKeywords: enumKeywords)) {
      result.add(consumeStructuredLiteral(stream, enumKeywords: enumKeywords));
    }

    return result;
  }

  /// Returns `true` if the current token is an asterisk (`*`), otherwise `false`.
  static bool isAsterisk(KiwiWatermelonTokenStream tokens) {
    return tokens.matchType(TokenTypes.asterisk);
  }

  /// Consumes the next token if it is an asterisk (`*`).
  ///
  /// Throws [KiwiWatermelonSemanticException] if the token is not an asterisk.
  static void consumeAsterisk(KiwiWatermelonTokenStream tokens,
      {String? contextual}) {
    tokens.consumeAndValidate(TokenTypes.asterisk, contextual: contextual);
  }

  /// Consumes a pattern-based key, allowing `*` as a segment.
  ///
  /// Accepts input like:
  /// - `env:user:*`
  /// - `env:*`
  /// - `env:shape:red:*`
  ///
  /// Each segment must be an identifier or an asterisk, delimited by colons.
  ///
  /// Throws [KiwiWatermelonSemanticException] if malformed.
  static String consumePatternKey(KiwiWatermelonTokenStream tokens) {
    final buffer = StringBuffer();

    void expectSegment() {
      if (isAsterisk(tokens)) {
        consumeAsterisk(tokens);
        buffer.write('*');
      } else {
        final ident = consumeIdentifier(tokens);
        buffer.write(ident.text);
      }
    }

    // First segment
    expectSegment();

    while (isColon(tokens)) {
      consumeColon(tokens);
      buffer.write(':');
      expectSegment();
    }

    return buffer.toString();
  }

  /// Consumes multiple space-separated pattern keys from the stream.
  ///
  /// Each key may include `*` wildcards, and segments must be delimited by colons (`:`).
  ///
  /// Example:
  ///   `cache:views:* cache:users:*` → ['cache:views:*', 'cache:users:*']
  ///
  /// Throws [KiwiWatermelonSemanticException] if any key is malformed.
  static List<String> consumePatternKeys(KiwiWatermelonTokenStream stream) {
    final keys = <String>[];

    while (!stream.isAtEnd) {
      final key = consumePatternKey(stream);
      keys.add(key);
    }

    return keys;
  }
}
