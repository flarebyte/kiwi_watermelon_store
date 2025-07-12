import 'token.dart';

/// Returns `true` if [char] is a whitespace character.
bool isWhitespace(String char) =>
    char == ' ' || char == '\t' || char == '\n' || char == '\r';

/// Returns `true` if [char] is the underscore character.
bool isUnderscore(String char) => char == '_';

/// Returns `true` if [char] is the dash character.
bool isDash(String char) => char == '-';

/// Returns `true` if [char] is an alphabetic letter.
bool isLetter(String char) => RegExp(r'[a-zA-Z]').hasMatch(char);

/// Returns `true` if [char] is a digit.
bool isDigit(String char) => RegExp(r'[0-9]').hasMatch(char);

/// Returns `true` if [char] is a letter or a digit.
bool isLetterOrDigitOr_(String char) =>
    isLetter(char) || isDigit(char) || isUnderscore(char);

/// Returns `true` if [char] is a colon `:`.
bool isColon(String char) => char == ':';

/// Returns `true` if [char] is a semicolon `;`.
bool isSemicolon(String char) => char == ';';

/// Returns `true` if [char] is an asterisk `*`.
bool isAsterisk(String char) => char == '*';

/// Returns `true` if [char] is a hexadecimal character (0-9, a-f, A-F).
bool isHexChar(String char) => RegExp(r'[0-9a-fA-F]').hasMatch(char);

/// Returns `true` if [char] is a hexadecimal character part.
bool isHexOrDash(String char) => isHexChar(char) || isDash(char);

/// Returns `true` if [token] is a valid lowercase UUID (RFC 4122 version 1–5).
bool isUuid(String token) {
  final regex = RegExp(r'^[0-9a-f]{8}-' // 8 lowercase hex chars
      r'[0-9a-f]{4}-' // 4 lowercase hex chars
      r'[1-5][0-9a-f]{3}-' // version 1–5
      r'[89ab][0-9a-f]{3}-' // variant 1 (8–b)
      r'[0-9a-f]{12}$' // 12 lowercase hex chars
      );
  return regex.hasMatch(token);
}

/// Returns `true` if [token] is a float (e.g., `12.4`, `0.75`).
bool isFloat(String token) => RegExp(r'^\d+\.\d+$').hasMatch(token);

/// Returns `true` if [token] is an integer.
bool isInteger(String token) => RegExp(r'^\d+$').hasMatch(token);

/// Returns `true` if [char] can appear in a Redis-like key.
bool isKeyChar(String char) => isLetterOrDigitOr_(char) || isColon(char);

/// Determines whether a space should be inserted between two tokens.
///
/// Inserts a space if both tokens consist solely of alphanumeric characters.
bool needsSpace(KiwiWatermelonToken previous, KiwiWatermelonToken current) {
  return RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(previous.text) &&
      RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(current.text);
}
