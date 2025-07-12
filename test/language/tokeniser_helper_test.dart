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

      expect(isUuid('invalid-uuid'), isFalse);
      expect(isUuid('invalid-uuid'), isFalse);
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
}
