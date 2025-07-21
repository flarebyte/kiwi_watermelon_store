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

/// Returns the UUID string at the given [start] index in [code]
/// if it matches a valid lowercase UUID (RFC 4122 version 1–5).
///
/// Returns `null` if there are not enough characters or the substring
/// does not conform to the UUID format.
String? extractUuidAt(String code, int start) {
  const uuidLength = 36;

  if (start < 0 || start + uuidLength > code.length) {
    return null;
  }

  final candidate = code.substring(start, start + uuidLength);
  return isUuid(candidate) ? candidate : null;
}

/// Validates whether a string matches the expected SHA-256 hash format.
///
/// The expected format is: `sha256$<salt>$<hash>`, where:
/// - `<salt>` is a 128-bit value encoded as 32 hexadecimal characters.
/// - `<hash>` is a SHA-256 hash encoded as 64 hexadecimal characters.
///
/// This method is case-insensitive and does not verify the correctness of
/// the hash computation—only the structure.
///
/// Example:
/// ```dart
/// isHash('sha256$5f2d0c8a1e4f3b9d7a3e6f1c4a8b9d0c$9c56cc51b8d95d02d07a3d1d5662630a179cf9b9568e5479c879c2bd10a1a157');
/// // Returns: true
/// ```
///
/// Returns `true` if the string is a valid SHA-256 hash format, otherwise `false`.
bool isHash(String token) {
  final regex = RegExp(
    r'^sha256\$[a-f0-9]{32}\$[a-f0-9]{64}$',
    caseSensitive: false,
  );
  return regex.hasMatch(token);
}

/// Attempts to extract a SHA-256 formatted hash token at a specific offset.
///
/// The expected format is `sha256$<32-hex-salt>$<64-hex-hash>`,
/// with a total fixed length of 6 (prefix) + 1 + 32 + 1 + 64 = 104 characters.
///
/// Returns the extracted token if it matches the format at the given position;
/// otherwise returns `null`.
String? extractHashAt(String code, int start) {
  const tokenLength = 104;

  if (start < 0 || start + tokenLength > code.length) {
    return null;
  }

  final candidate = code.substring(start, start + tokenLength);
  return isHash(candidate) ? candidate : null;
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
