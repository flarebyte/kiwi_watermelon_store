import 'package:kiwi_watermelon_store/src/language/semantic_exception.dart';
import 'package:kiwi_watermelon_store/src/language/token_stream.dart';
import 'package:kiwi_watermelon_store/src/language/token_stream_flyweight.dart';
import 'package:kiwi_watermelon_store/src/language/tokeniser.dart';
import 'package:test/test.dart';

import '../code_fixtures.dart';

void main() {
  final tokeniser = KiwiWatermelonTokeniser();
  KiwiWatermelonTokenStream toStream(String code) {
    final tokens = tokeniser.parse(code);
    final tokenStream = KiwiWatermelonTokenStream(tokens);
    return tokenStream;
  }

  group('consumeIdentifier', () {
    test('consumes identifier when token matches', () {
      final result =
          KiwiTokenStreamFlyweight.consumeIdentifier(toStream('INCR env:flag'));

      expect(result.text, equals("INCR"));
      expect(result.type, equals(TokenTypes.identifier));
    });

    test('throws SemanticException when token is not identifier', () {
      expect(
          () => KiwiTokenStreamFlyweight.consumeIdentifier(
              toStream('12 INCR env:flag')),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });
  group('Semicolon Methods', () {
    test('peekIsSemicolon returns true for semicolon', () {
      expect(
          KiwiTokenStreamFlyweight.peekIsSemicolon(toStream('INCR ;')), isTrue);
    });

    test('peekIsSemicolon returns false for non-semicolon', () {
      expect(KiwiTokenStreamFlyweight.peekIsSemicolon(toStream('INCR ,')),
          isFalse);
    });

    test('consumeSemicolon consumes semicolon successfully', () {
      final stream = toStream(';');
      KiwiTokenStreamFlyweight.consumeSemicolon(stream);
      expect(stream.isAtEnd, isTrue);
    });

    test('consumeSemicolon throws if not semicolon', () {
      expect(
          () => KiwiTokenStreamFlyweight.consumeSemicolon(
              toStream('12 INCR env:flag')),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('Colon Methods', () {
    test('peekIsColon returns true for colon', () {
      expect(
          KiwiTokenStreamFlyweight.peekIsColon(toStream('env:other')), isTrue);
    });

    test('peekIsColon returns false for non-colon', () {
      expect(KiwiTokenStreamFlyweight.peekIsColon(toStream('12 INCR env:flag')),
          isFalse);
    });

    test('consumeColon consumes colon successfully', () {
      final stream = toStream(':');
      KiwiTokenStreamFlyweight.consumeColon(stream);
      expect(stream.isAtEnd, isTrue);
    });

    test('consumeColon throws if not colon', () {
      expect(
          () => KiwiTokenStreamFlyweight.consumeColon(
              toStream('12 INCR env:flag')),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('isSemicolon', () {
    test('returns true when current token is semicolon', () {
      final result = KiwiTokenStreamFlyweight.isSemicolon(toStream(';'));
      expect(result, isTrue);
    });

    test('returns false when current token is not semicolon', () {
      final result = KiwiTokenStreamFlyweight.isSemicolon(toStream('other'));
      expect(result, isFalse);
    });
  });

  group('isColon', () {
    test('returns true when current token is colon', () {
      final result = KiwiTokenStreamFlyweight.isColon(toStream(':'));
      expect(result, isTrue);
    });

    test('returns false when current token is not colon', () {
      final result = KiwiTokenStreamFlyweight.isColon(toStream('other'));
      expect(result, isFalse);
    });
  });

  group('Any keyword Methods', () {
    test('isAnyKeyword returns true for known keyword', () {
      expect(
          KiwiTokenStreamFlyweight.isAnyKeyword(
              toStream('INCR'), ['INCR', 'DECR']),
          isTrue);
    });

    test('isAnyKeyword returns false for unknown keyword', () {
      expect(
          KiwiTokenStreamFlyweight.isAnyKeyword(
              toStream('DDD'), ['INCR', 'DECR']),
          isFalse);
    });

    test('peekIsAnyKeyword returns true for known keyword', () {
      expect(
          KiwiTokenStreamFlyweight.peekIsAnyKeyword(
              toStream('next INCR'), ['INCR', 'DECR']),
          isTrue);
    });

    test('peekIsAnyKeyword returns false for unknown keyword', () {
      expect(
          KiwiTokenStreamFlyweight.peekIsAnyKeyword(
              toStream('next DDD'), ['INCR', 'DECR']),
          isFalse);
    });
  });
  group('Composite variable', () {
    for (final expected in [
      'env:flag',
      'env:on_off:yes:color:blue',
      'env:on_off:yes :color:blue',
      'env : on_off : yes : color : blue'
    ]) {
      test('consumes composite variable $expected', () {
        final actual = KiwiTokenStreamFlyweight.consumeCompositeVariable(
            toStream(expected),
            options: storeOptions);

        expect(actual, equals(expected.replaceAll(' ', '')));
      });
    }
    var longVar = "";
    for (var i = 0; i < 16; i++) {
      longVar = longVar + 'a$i:b$i';
    }
    for (final unsupported in [
      'env:flag:',
      'env:flag::red',
      'env:long:$longVar'
    ]) {
      test('consumeCompositeVariable throws if not a valid one', () {
        expect(
            () => KiwiTokenStreamFlyweight.consumeCompositeVariable(
                toStream(unsupported),
                options: storeOptions),
            throwsA(isA<KiwiWatermelonSemanticException>()));
      });
    }
  });

  group('consumeInteger', () {
    test('consumes integer', () {
      final actual = KiwiTokenStreamFlyweight.consumeInteger(toStream('12'));

      expect(actual, equals(12));
    });
    test('consumeInteger throws if not a valid one', () {
      expect(() => KiwiTokenStreamFlyweight.consumeInteger(toStream('three')),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });
}
