import 'package:kiwi_watermelon_store/src/language/token.dart';
import 'package:kiwi_watermelon_store/src/language/tokeniser.dart';
import 'package:kiwi_watermelon_store/src/language/tokeniser_helper.dart';
import 'package:test/test.dart';

void main() {
  group('isWhitespace', () {
    test('returns true for space, tab, newline, and carriage return', () {
      expect(isWhitespace(' '), isTrue);
      expect(isWhitespace('\t'), isTrue);
      expect(isWhitespace('\n'), isTrue);
      expect(isWhitespace('\r'), isTrue);
    });

    test('returns false for non-whitespace characters', () {
      expect(isWhitespace('a'), isFalse);
      expect(isWhitespace('1'), isFalse);
      expect(isWhitespace(','), isFalse);
    });
  });

  group('isLetter', () {
    test('returns true for letters', () {
      expect(isLetter('a'), isTrue);
      expect(isLetter('Z'), isTrue);
    });

    test('returns false for non-letter characters', () {
      expect(isLetter('1'), isFalse);
      expect(isLetter(' '), isFalse);
      expect(isLetter('?'), isFalse);
    });
  });

  group('isDigit', () {
    test('returns true for digit characters', () {
      expect(isDigit('0'), isTrue);
      expect(isDigit('9'), isTrue);
    });

    test('returns false for non-digit characters', () {
      expect(isDigit('a'), isFalse);
      expect(isDigit(' '), isFalse);
      expect(isDigit('!'), isFalse);
    });
  });

  group('isLetterOrDigitOr_', () {
    test('returns true for letters and digits', () {
      expect(isLetterOrDigitOr_('a'), isTrue);
      expect(isLetterOrDigitOr_('Z'), isTrue);
      expect(isLetterOrDigitOr_('0'), isTrue);
      expect(isLetterOrDigitOr_('9'), isTrue);
      expect(isLetterOrDigitOr_('_'), isTrue);
    });

    test('returns false for non-alphanumeric characters', () {
      expect(isLetterOrDigitOr_(' '), isFalse);
      expect(isLetterOrDigitOr_('@'), isFalse);
      expect(isLetterOrDigitOr_(','), isFalse);
    });
  });

  group('needsSpace', () {
    // Create some dummy tokens with minimal positional info.
    final tokenHello = KiwiWatermelonToken(
      type: TokenTypes.identifier,
      text: 'hello',
      startIndex: 0,
      endIndex: 5,
      startPosition: KiwiWatermelonPosition(row: 0, column: 0),
      endPosition: KiwiWatermelonPosition(row: 0, column: 5),
    );

    final tokenWorld = KiwiWatermelonToken(
      type: TokenTypes.identifier,
      text: 'world',
      startIndex: 6,
      endIndex: 11,
      startPosition: KiwiWatermelonPosition(row: 0, column: 6),
      endPosition: KiwiWatermelonPosition(row: 0, column: 11),
    );

    final tokenComma = KiwiWatermelonToken(
      type: TokenTypes.comma,
      text: ',',
      startIndex: 5,
      endIndex: 6,
      startPosition: KiwiWatermelonPosition(row: 0, column: 5),
      endPosition: KiwiWatermelonPosition(row: 0, column: 6),
    );

    final tokenUnderscore = KiwiWatermelonToken(
      type: TokenTypes.identifier,
      text: 'foo_bar',
      startIndex: 12,
      endIndex: 19,
      startPosition: KiwiWatermelonPosition(row: 0, column: 12),
      endPosition: KiwiWatermelonPosition(row: 0, column: 19),
    );

    test('returns true when both tokens are alphanumeric', () {
      expect(needsSpace(tokenHello, tokenWorld), isTrue);
      expect(needsSpace(tokenHello, tokenUnderscore), isTrue);
    });

    test('returns false when one token is not alphanumeric', () {
      expect(needsSpace(tokenHello, tokenComma), isFalse);
      expect(needsSpace(tokenComma, tokenWorld), isFalse);
    });
  });

  group('Character helpers', () {
    test('isColon', () {
      expect(isColon(':'), isTrue);
      expect(isColon('/'), isFalse);
    });

    test('isSemicolon', () {
      expect(isSemicolon(';'), isTrue);
      expect(isSemicolon(','), isFalse);
    });

    test('isAsterisk', () {
      expect(isAsterisk('*'), isTrue);
      expect(isAsterisk('#'), isFalse);
    });

    test('isHexChar', () {
      expect(isHexChar('f'), isTrue);
      expect(isHexChar('A'), isTrue);
      expect(isHexChar('9'), isTrue);
      expect(isHexChar('g'), isFalse);
    });
  });

  group('Pattern helpers', () {
    test('isUuid', () {
      expect(isUuid('9df93b15-646f-4f52-aa3d-cbadb57173f7'), isTrue);
      expect(isUuid('12345678-1234-4234-8234-123456789012'), isTrue);
      expect(isUuid('6ba7b810-9dad-11d1-80b4-00c04fd430c8'), isTrue,
          reason: 'Version 1, variant 1 (RFC 4122)');
      expect(isUuid('f47ac10b-58cc-3372-a567-0e02b2c3d479'), isTrue,
          reason: 'Version 3, variant 1 (RFC 4122)');
      expect(isUuid('12345678-1234-4234-8234-123456789012'), isTrue,
          reason: 'Version 4, variant 1 (RFC 4122), digit-only');
      expect(isUuid('21f7f8de-8051-5b89-bb08-2d3a7b5a0b45'), isTrue,
          reason: 'Version 5, variant 1 (RFC 4122)');
      expect(isUuid('00000000-0000-4000-8000-000000000000'), isTrue,
          reason: 'Version 4, variant 1, minimal hex characters');
      expect(isUuid('12345678-1234-1234-1234-123456789012'), isFalse,
          reason: 'Invalid version and variant: 13th != 1–5, 17th != 8–b');
      expect(isUuid('6ba7b810-9dad-11d1-70b4-00c04fd430c8'), isFalse,
          reason: 'Invalid variant: 17th character is 7 (should be 8–b)');
      expect(isUuid('f47ac10b-58cc-6372-a567-0e02b2c3d479'), isFalse,
          reason: 'Invalid version: 13th character is 6 (should be 1–5)');
      expect(isUuid('00000000-0000-0000-0000-000000000000'), isFalse,
          reason: 'Invalid version and variant: no version/variant bits set');
      expect(isUuid('g47ac10b-58cc-4372-a567-0e02b2c3d479'), isFalse,
          reason: 'Invalid character: contains non-hex letter (g)');
      expect(isUuid('21f7f8de80515b89bb082d3a7b5a0b45'), isFalse,
          reason: 'Missing hyphens: not in UUID format');
      expect(isUuid('21f7f8de-8051-5b89-bb08-2d3a7b5a0b4'), isFalse,
          reason: 'Too short: last segment is 11 digits instead of 12');
      expect(isUuid('9DF93B15-646F-4F52-AA3D-CBADB57173F7'), isFalse);

      expect(isUuid('invalid-uuid'), isFalse);
      expect(isUuid('invalid-uuid'), isFalse);
    });

    group('extractUuidAt', () {
      const validUuid = '123e4567-e89b-12d3-a456-426614174000';

      test('returns UUID when found at exact start', () {
        final result = extractUuidAt(validUuid, 0);
        expect(result, equals(validUuid));
      });

      test('returns UUID when found at offset', () {
        final input = 'abc $validUuid xyz';
        final result = extractUuidAt(input, 4);
        expect(result, equals(validUuid));
      });

      test('returns null if not enough characters', () {
        final result = extractUuidAt('abc', 1);
        expect(result, isNull);
      });

      test('returns null for invalid format', () {
        final invalidUuid = '123e4567-e89b-12d3-a456-zzzzzzzzzzzz';
        final result = extractUuidAt(invalidUuid, 0);
        expect(result, isNull);
      });

      test('returns null if start index is negative', () {
        final result = extractUuidAt(validUuid, -1);
        expect(result, isNull);
      });

      test('returns null if start + 36 exceeds input length', () {
        final result = extractUuidAt(validUuid, 1); // validUuid.length == 36
        expect(result, isNull);
      });
    });
    test('isFloat', () {
      expect(isFloat('0.75'), isTrue);
      expect(isFloat('12.0'), isTrue);
      expect(isFloat('12.'), isFalse);
      expect(isFloat('.25'), isFalse);
    });

    test('isInteger', () {
      expect(isInteger('42'), isTrue);
      expect(isInteger('0'), isTrue);
      expect(isInteger('3.14'), isFalse);
    });

    test('isKeyChar', () {
      expect(isKeyChar('a'), isTrue);
      expect(isKeyChar(':'), isTrue);
      expect(isKeyChar('7'), isTrue);
      expect(isKeyChar('@'), isFalse);
    });
  });
  group('isHash', () {
    test('returns true for a valid sha256\$<salt>\$<hash> format', () {
      final validToken =
          'sha256\$5f2d0c8a1e4f3b9d7a3e6f1c4a8b9d0c\$9c56cc51b8d95d02d07a3d1d5662630a179cf9b9568e5479c879c2bd10a1a157';
      expect(isHash(validToken), isTrue);
    });

    test('rejects missing sha256 prefix', () {
      final invalidToken =
          '5f2d0c8a1e4f3b9d7a3e6f1c4a8b9d0c\$9c56cc51b8d95d02d07a3d1d5662630a179cf9b9568e5479c879c2bd10a1a157';
      expect(isHash(invalidToken), isFalse);
    });

    test('rejects invalid salt length', () {
      final invalidToken =
          'sha256\$abcd\$9c56cc51b8d95d02d07a3d1d5662630a179cf9b9568e5479c879c2bd10a1a157';
      expect(isHash(invalidToken), isFalse);
    });

    test('rejects invalid hash length', () {
      final invalidToken = 'sha256\$5f2d0c8a1e4f3b9d7a3e6f1c4a8b9d0c\$abcd';
      expect(isHash(invalidToken), isFalse);
    });

    test('rejects non-hexadecimal characters', () {
      final invalidToken =
          'sha256\$5f2d0c8a1e4f3b9d7a3e6f1c4a8b9d0c\$zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz';
      expect(isHash(invalidToken), isFalse);
    });

    test('accepts uppercase hexadecimal characters', () {
      final validToken =
          'sha256\$5F2D0C8A1E4F3B9D7A3E6F1C4A8B9D0C\$9C56CC51B8D95D02D07A3D1D5662630A179CF9B9568E5479C879C2BD10A1A157';
      expect(isHash(validToken), isTrue);
    });
  });
}
