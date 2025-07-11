import 'token.dart';
import 'tokeniser_helper.dart';

/// Defines all supported token types for the Rhapsody language.
class TokenTypes {
  static const String identifier = 'identifier';
  static const String number = 'number';
  static const String float = 'float';
  static const String uuid = 'uuid';
  static const String lparen = 'lparen'; //we may not need this
  static const String rparen = 'rparen'; //we may not need this
  static const String comma = 'comma';
  static const String semicolon = 'semicolon';
  static const String colon = 'colon';
  static const String asterisk = 'asterisk';
  static const String comment = 'comment';
  static const String unknown = 'unknown';
}

/// A lightweight tokeniser for Rhapsody rule expressions.
///
/// This class converts a source [code] string into a sequence of [KiwiWatermelonToken]s,
/// preserving positional information for accurate error reporting and debugging.
/// It now captures line comments as tokens and uses constants for token types.
class KiwiWatermelonTokeniser {
  /// This tokeniser processes a textual representation of the Rhapsody rule language,
  /// splitting the source code into a sequence of lexical tokens. It recognizes:
  ///   - Identifiers (including prefixed variables like "prefix:a")
  ///   - Numeric literals
  ///   - Logical operators ("and", "or", "not")
  ///   - Punctuation (parentheses, commas, colons, semicolons, etc.)
  ///   - Comments (lines starting with "#")
  ///
  /// For each token, the tokeniser records precise positional information (start/end indices,
  /// as well as line and column positions) to facilitate detailed error reporting and later analysis.
  ///
  /// The grammar supported includes function calls with arguments, grouped expressions using
  /// parentheses, and complete rule declarations (e.g., "rule 23 = (func1(prefix:a) or func2(b))
  /// and not rule42;"). This design focuses solely on lexical analysis, deferring semantic
  /// validation to subsequent stages.
  KiwiWatermelonTokeniser();

  /// Parses the provided [code] into a list of [KiwiWatermelonToken]s.
  List<KiwiWatermelonToken> parse(String code) {
    final List<KiwiWatermelonToken> tokens = [];
    int index = 0;
    int line = 0;
    int column = 0;

    while (index < code.length) {
      final String currentChar = code[index];

      // Skip whitespace while updating position.
      if (isWhitespace(currentChar)) {
        if (currentChar == '\n') {
          line++;
          column = 0;
        } else {
          column++;
        }
        index++;
        continue;
      }

      final int tokenStartIndex = index;
      final KiwiWatermelonPosition startPosition =
          KiwiWatermelonPosition(row: line, column: column);

      // Capture comments starting with '#'.
      if (currentChar == '#') {
        while (index < code.length && code[index] != '\n') {
          index++;
          column++;
        }
        final String tokenText = code.substring(tokenStartIndex, index);
        final KiwiWatermelonPosition endPosition =
            KiwiWatermelonPosition(row: line, column: column);
        tokens.add(KiwiWatermelonToken(
          type: TokenTypes.comment,
          text: tokenText,
          startIndex: tokenStartIndex,
          endIndex: index,
          startPosition: startPosition,
          endPosition: endPosition,
        ));
        continue;
      }

      // Identify identifiers or UUIDs.
      if (isLetter(currentChar)) {
        while (index < code.length &&
            (isLetterOrDigitOr_(code[index]) || isDash(code[index]))) {
          index++;
          column++;
        }
        final String tokenText = code.substring(tokenStartIndex, index);
        final String tokenType =
            isUuid(tokenText) ? TokenTypes.uuid : TokenTypes.identifier;

        final KiwiWatermelonPosition endPosition =
            KiwiWatermelonPosition(row: line, column: column);

        tokens.add(KiwiWatermelonToken(
          type: tokenType,
          text: tokenText,
          startIndex: tokenStartIndex,
          endIndex: index,
          startPosition: startPosition,
          endPosition: endPosition,
        ));
        continue;
      }

      // Identify number, float, or UUID (starting with digit).
      if (isDigit(currentChar)) {
        int tempIndex = index;
        int tempColumn = column;

        while (tempIndex < code.length &&
            (isHexChar(code[tempIndex]) || isDash(code[tempIndex]))) {
          tempIndex++;
          tempColumn++;
        }

        final String candidate = code.substring(index, tempIndex);

        if (isUuid(candidate)) {
          index = tempIndex;
          column = tempColumn;
          final KiwiWatermelonPosition endPosition =
              KiwiWatermelonPosition(row: line, column: column);
          tokens.add(KiwiWatermelonToken(
            type: TokenTypes.uuid,
            text: candidate,
            startIndex: tokenStartIndex,
            endIndex: index,
            startPosition: startPosition,
            endPosition: endPosition,
          ));
          continue;
        }

        // Standard number or float
        bool hasDot = false;
        while (index < code.length) {
          if (isDigit(code[index])) {
            index++;
            column++;
          } else if (!hasDot &&
              code[index] == '.' &&
              index + 1 < code.length &&
              isDigit(code[index + 1])) {
            hasDot = true;
            index++;
            column++;
          } else {
            break;
          }
        }

        final String tokenText = code.substring(tokenStartIndex, index);
        final KiwiWatermelonPosition endPosition =
            KiwiWatermelonPosition(row: line, column: column);
        tokens.add(KiwiWatermelonToken(
          type: hasDot ? TokenTypes.float : TokenTypes.number,
          text: tokenText,
          startIndex: tokenStartIndex,
          endIndex: index,
          startPosition: startPosition,
          endPosition: endPosition,
        ));
        continue;
      }

      // Process single-character tokens.
      String tokenType;
      switch (currentChar) {
        case '(':
          tokenType = TokenTypes.lparen;
          break;
        case ')':
          tokenType = TokenTypes.rparen;
          break;
        case ',':
          tokenType = TokenTypes.comma;
          break;
        case ';':
          tokenType = TokenTypes.semicolon;
          break;
        case ':':
          tokenType = TokenTypes.colon;
          break;
        case '*':
          tokenType = TokenTypes.asterisk;
          break;
        default:
          tokenType = TokenTypes.unknown;
      }

      index++;
      column++;
      final String tokenText = code.substring(tokenStartIndex, index);
      final KiwiWatermelonPosition endPosition =
          KiwiWatermelonPosition(row: line, column: column);
      tokens.add(KiwiWatermelonToken(
        type: tokenType,
        text: tokenText,
        startIndex: tokenStartIndex,
        endIndex: index,
        startPosition: startPosition,
        endPosition: endPosition,
        hasError: tokenType == TokenTypes.unknown,
      ));
    }

    return tokens;
  }

  /// Reconstructs the source code from a list of [tokens].
  String unparse(List<KiwiWatermelonToken> tokens) {
    if (tokens.isEmpty) return '';
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < tokens.length; i++) {
      if (i > 0 && needsSpace(tokens[i - 1], tokens[i])) {
        buffer.write(' ');
      }
      buffer.write(tokens[i].text);
    }
    return buffer.toString();
  }
}
