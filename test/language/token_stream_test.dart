import 'package:kiwi_watermelon_store/src/language/semantic_exception.dart';
import 'package:kiwi_watermelon_store/src/language/token.dart';
import 'package:kiwi_watermelon_store/src/language/token_stream.dart';
import 'package:test/test.dart';

void main() {
  group('KiwiWatermelonTokenStream', () {
    late List<KiwiWatermelonToken> tokens;
    late KiwiWatermelonTokenStream stream;

    setUp(() {
      tokens = [
        KiwiWatermelonToken(
            type: 'IDENTIFIER',
            text: 'foo',
            startIndex: 0,
            endIndex: 10,
            startPosition: KiwiWatermelonPosition(row: 1, column: 10),
            endPosition: KiwiWatermelonPosition(row: 2, column: 15)),
        KiwiWatermelonToken(
            type: 'OPERATOR',
            text: 'and',
            startIndex: 0,
            endIndex: 10,
            startPosition: KiwiWatermelonPosition(row: 1, column: 10),
            endPosition: KiwiWatermelonPosition(row: 2, column: 15)),
        KiwiWatermelonToken(
            type: 'IDENTIFIER',
            text: 'bar',
            startIndex: 0,
            endIndex: 10,
            startPosition: KiwiWatermelonPosition(row: 1, column: 10),
            endPosition: KiwiWatermelonPosition(row: 2, column: 15)),
      ];
      stream = KiwiWatermelonTokenStream(tokens);
    });

    // Existing tests (kept as-is)
    test('isAtEnd should be false initially', () {
      expect(stream.isAtEnd, isFalse);
    });

    test('current should return first token without consuming', () {
      expect(stream.current, equals(tokens[0]));
      expect(stream.isAtEnd, isFalse);
    });

    test('consume should return tokens in order', () {
      expect(stream.consume(), equals(tokens[0]));
      expect(stream.consume(), equals(tokens[1]));
      expect(stream.consume(), equals(tokens[2]));
      expect(stream.isAtEnd, isTrue);
    });

    test('consume should throw when at end', () {
      stream.consume();
      stream.consume();
      stream.consume();
      expect(() => stream.consume(),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });

    test('matchType should correctly check token type', () {
      expect(stream.matchType('IDENTIFIER'), isTrue);
      expect(stream.matchType('OPERATOR'), isFalse);
      stream.consume();
      expect(stream.matchType('OPERATOR'), isTrue);
    });

    test('remainingTokens should return unconsumed tokens', () {
      expect(stream.remainingTokens, equals(tokens));
      stream.consume();
      expect(stream.remainingTokens, equals(tokens.sublist(1)));
    });

    test('current should throw when at end', () {
      stream.consume();
      stream.consume();
      stream.consume();
      expect(() => stream.current,
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });

    // 🔥 New tests for uncovered methods and edge cases

    test('isNextAtEnd should correctly handle lookahead', () {
      expect(stream.isNextAtEnd(lookahead: 2), isFalse);
      expect(stream.isNextAtEnd(lookahead: 3), isTrue); // Exact length
      expect(stream.isNextAtEnd(lookahead: 5), isTrue); // Beyond length
    });

    test('peekMatchesType should validate lookahead token type', () {
      expect(
          stream.peekMatchesType('OPERATOR'), isTrue); // Default lookahead = 1
      expect(stream.peekMatchesType('IDENTIFIER', lookahead: 2), isTrue);
      expect(stream.peekMatchesType('OPERATOR', lookahead: 5),
          isFalse); // Out of range
    });

    test('matchText should correctly check token text', () {
      expect(stream.matchText('foo'), isTrue);
      expect(stream.matchText('bar'), isFalse);
      stream.consume();
      expect(stream.matchText('and'), isTrue);
    });

    test('peekMatchesText should validate lookahead token text', () {
      expect(stream.peekMatchesText('and'), isTrue); // Next token text
      expect(stream.peekMatchesText('bar', lookahead: 2), isTrue);
      expect(stream.peekMatchesText('baz', lookahead: 1), isFalse);
    });

    test('peekMatchesText should return false if lookahead exceeds length', () {
      expect(stream.peekMatchesText('foo', lookahead: 5), isFalse);
    });

    group('consumeAndValidate', () {
      test('should consume and validate token type and text successfully', () {
        final token = stream.consumeAndValidate('IDENTIFIER', text: 'foo');
        expect(token, equals(tokens[0]));
      });

      test('should throw if type does not match', () {
        expect(() => stream.consumeAndValidate('OPERATOR', text: 'foo'),
            throwsA(isA<KiwiWatermelonSemanticException>()));
      });

      test('should throw if text does not match', () {
        expect(() => stream.consumeAndValidate('IDENTIFIER', text: 'bar'),
            throwsA(isA<KiwiWatermelonSemanticException>()));
      });

      test('should handle null text parameter (type-only validation)', () {
        final token = stream.consumeAndValidate('IDENTIFIER');
        expect(token, equals(tokens[0]));
      });

      test('should consume and validate multiple tokens correctly', () {
        expect(stream.consumeAndValidate('IDENTIFIER', text: 'foo'),
            equals(tokens[0]));
        expect(stream.consumeAndValidate('OPERATOR', text: 'and'),
            equals(tokens[1]));
        expect(stream.consumeAndValidate('IDENTIFIER', text: 'bar'),
            equals(tokens[2]));
        expect(stream.isAtEnd, isTrue);
      });

      test('should throw if validate is called at end of stream', () {
        stream.consume();
        stream.consume();
        stream.consume();
        expect(() => stream.consumeAndValidate('IDENTIFIER', text: 'baz'),
            throwsA(isA<KiwiWatermelonSemanticException>()));
      });
    });
  });
}
