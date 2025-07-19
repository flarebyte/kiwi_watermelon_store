import '../store/manager_options.dart';
import 'semantic_exception.dart';
import 'token.dart';
import 'token_stream.dart';
import 'tokeniser.dart';

/// Represents a strictly accepted literal parsed from a command stream.
sealed class ParsedLiteral {
  final KiwiWatermelonToken token;

  const ParsedLiteral(this.token);

  /// Returns the string representation of the literal value.
  String get asString;

  T valueAs<T>() {
    if (this is ParsedInteger && T == int)
      return (this as ParsedInteger).value as T;
    if (this is ParsedFloat && T == double)
      return (this as ParsedFloat).value as T;
    if (this is ParsedUuid && T == String)
      return (this as ParsedUuid).value as T;
    if (this is ParsedEnum && T == String)
      return (this as ParsedEnum).value as T;
    throw StateError('Invalid type access on ParsedLiteral');
  }
}

final class ParsedInteger extends ParsedLiteral {
  final int value;
  const ParsedInteger(this.value, super.token);
  @override
  String get asString => value.toString();
}

final class ParsedFloat extends ParsedLiteral {
  final double value;
  const ParsedFloat(this.value, super.token);
  @override
  String get asString => value.toString();
}

final class ParsedUuid extends ParsedLiteral {
  final String value;
  const ParsedUuid(this.value, super.token);
  @override
  String get asString => value;
}

final class ParsedEnum extends ParsedLiteral {
  final String value;
  const ParsedEnum(this.value, super.token);
  @override
  String get asString => value;
}

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

  /// Checks if the next token is a comma (`comma`) without consuming it.
  ///
  /// Returns `true` if the next token is a comma; otherwise, `false`.
  static bool peekIsComma(KiwiWatermelonTokenStream tokens) {
    return tokens.peekMatchesType(TokenTypes.comma);
  }

  /// Consumes the next token if it is a comma (`comma`).
  ///
  /// Throws a [KiwiWatermelonSemanticException] if the next token is not a comma.
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

  /// Checks if the current token is float).
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
      return ParsedInteger(value, stream.current);
    }

    if (isFloat(stream)) {
      final value = consumeDouble(stream);
      return ParsedFloat(value, stream.current);
    }

    if (isUuid(stream)) {
      final value = consumeUuid(stream);
      return ParsedUuid(value, stream.current);
    }

    if (isAnyKeyword(stream, enumKeywords)) {
      final value = consumeIdentifier(stream).text;
      return ParsedEnum(value, stream.current);
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

    while (!stream.isAtEnd) {
      result.add(consumeStructuredLiteral(stream, enumKeywords: enumKeywords));
    }

    return result;
  }
}
