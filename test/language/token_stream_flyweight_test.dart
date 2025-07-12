import 'package:kiwi_watermelon_store/src/language/semantic_exception.dart';
import 'package:kiwi_watermelon_store/src/language/token_stream.dart';
import 'package:kiwi_watermelon_store/src/language/token_stream_flyweight.dart';
import 'package:kiwi_watermelon_store/src/language/tokeniser.dart';
import 'package:test/test.dart';

void main() {
  final tokeniser = KiwiWatermelonTokeniser();
  KiwiWatermelonTokenStream toStream(String code) {
    final tokens = tokeniser.parse(code);
    final tokenStream = KiwiWatermelonTokenStream(tokens);
    return tokenStream;
  }

  group('KiwiWatermelonTokenStreamFlyweight.consumeIdentifier', () {
    test('consumes identifier when token matches', () {
      final result = KiwiWatermelonTokenStreamFlyweight.consumeIdentifier(
          toStream('INCR env:flag'));

      expect(result.text, equals("INCR"));
      expect(result.type, equals(TokenTypes.identifier));
    });

    test('throws SemanticException when token is not identifier', () {
      expect(
          () => KiwiWatermelonTokenStreamFlyweight.consumeIdentifier(
              toStream('12 INCR env:flag')),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });
  group('Semicolon Methods', () {
    test('peekIsSemicolon returns true for semicolon', () {
      expect(
          KiwiWatermelonTokenStreamFlyweight.peekIsSemicolon(
              toStream('INCR ;')),
          isTrue);
    });

    test('peekIsSemicolon returns false for non-semicolon', () {
      expect(
          KiwiWatermelonTokenStreamFlyweight.peekIsSemicolon(
              toStream('INCR ,')),
          isFalse);
    });

    test('consumeSemicolon consumes semicolon successfully', () {
      final stream = toStream(';');
      KiwiWatermelonTokenStreamFlyweight.consumeSemicolon(stream);
      expect(stream.isAtEnd, isTrue);
    });

    test('consumeSemicolon throws if not semicolon', () {
      expect(
          () => KiwiWatermelonTokenStreamFlyweight.consumeSemicolon(
              toStream('12 INCR env:flag')),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('Colon Methods', () {
    test('peekIsColon returns true for colon', () {
      expect(
          KiwiWatermelonTokenStreamFlyweight.peekIsColon(toStream('env:other')),
          isTrue);
    });

    test('peekIsColon returns false for non-colon', () {
      expect(
          KiwiWatermelonTokenStreamFlyweight.peekIsColon(
              toStream('12 INCR env:flag')),
          isFalse);
    });

    test('consumeColon consumes colon successfully', () {
      final stream = toStream(':');
      KiwiWatermelonTokenStreamFlyweight.consumeColon(stream);
      expect(stream.isAtEnd, isTrue);
    });

    test('consumeColon throws if not colon', () {
      expect(
          () => KiwiWatermelonTokenStreamFlyweight.consumeColon(
              toStream('12 INCR env:flag')),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('KiwiWatermelonTokenStreamFlyweight.isSemicolon', () {
    test('returns true when current token is semicolon', () {
      final result =
          KiwiWatermelonTokenStreamFlyweight.isSemicolon(toStream(';'));
      expect(result, isTrue);
    });

    test('returns false when current token is not semicolon', () {
      final result =
          KiwiWatermelonTokenStreamFlyweight.isSemicolon(toStream('other'));
      expect(result, isFalse);
    });
  });

  group('KiwiWatermelonTokenStreamFlyweight.isColon', () {
    test('returns true when current token is colon', () {
      final result = KiwiWatermelonTokenStreamFlyweight.isColon(toStream(':'));
      expect(result, isTrue);
    });

    test('returns false when current token is not colon', () {
      final result =
          KiwiWatermelonTokenStreamFlyweight.isColon(toStream('other'));
      expect(result, isFalse);
    });
  });

  group('Any keyword Methods', () {
    test('isAnyKeyword returns true for known keyword', () {
      expect(
          KiwiWatermelonTokenStreamFlyweight.isAnyKeyword(
              toStream('INCR'), ['INCR', 'DECR']),
          isTrue);
    });

    test('isAnyKeyword returns false for unknown keyword', () {
      expect(
          KiwiWatermelonTokenStreamFlyweight.isAnyKeyword(
              toStream('DDD'), ['INCR', 'DECR']),
          isFalse);
    });

    test('peekIsAnyKeyword returns true for known keyword', () {
      expect(
          KiwiWatermelonTokenStreamFlyweight.peekIsAnyKeyword(
              toStream('next INCR'), ['INCR', 'DECR']),
          isTrue);
    });

    test('peekIsAnyKeyword returns false for unknown keyword', () {
      expect(
          KiwiWatermelonTokenStreamFlyweight.peekIsAnyKeyword(
              toStream('next DDD'), ['INCR', 'DECR']),
          isFalse);
    });
  });
}
