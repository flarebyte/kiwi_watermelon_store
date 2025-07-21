import 'package:kiwi_watermelon_store/src/language/literal.dart';
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

  group('Integer or Number', () {
    test('returns true when current token is a number', () {
      final result = KiwiTokenStreamFlyweight.isNumber(toStream('12'));
      expect(result, isTrue);
    });

    test('returns false when current token is not a number', () {
      final result = KiwiTokenStreamFlyweight.isNumber(toStream('other'));
      expect(result, isFalse);
    });
    test('consumes integer', () {
      final actual = KiwiTokenStreamFlyweight.consumeInteger(toStream('12'));

      expect(actual, equals(12));
    });
    test('consumeInteger throws if not a valid one', () {
      expect(() => KiwiTokenStreamFlyweight.consumeInteger(toStream('three')),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('consumeDouble', () {
    test('consumes float or double', () {
      final actual = KiwiTokenStreamFlyweight.consumeDouble(toStream('12.761'));

      expect(actual, equals(12.761));
    });
    test('consumeInteger throws if not a valid one', () {
      expect(() => KiwiTokenStreamFlyweight.consumeDouble(toStream('three')),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('UUID', () {
    test('returns true when current token is a UUID', () {
      final result = KiwiTokenStreamFlyweight.isUuid(
          toStream('e3ff1563-6977-4824-800a-be7118b22deb'));
      expect(result, isTrue);
    });

    test('returns false when current token is not a UUID', () {
      final result = KiwiTokenStreamFlyweight.isUuid(toStream('other'));
      expect(result, isFalse);
    });
  });

  group('isStructuredLiteral', () {
    const enumKeywords = ['RED', 'GREEN', 'BLUE'];
    test('returns true for int', () {
      final stream = toStream('42');
      expect(
          KiwiTokenStreamFlyweight.isStructuredLiteral(stream,
              enumKeywords: enumKeywords),
          isTrue);
    });

    test('returns true for float', () {
      final stream = toStream('3.14');
      expect(
          KiwiTokenStreamFlyweight.isStructuredLiteral(stream,
              enumKeywords: enumKeywords),
          isTrue);
    });

    test('returns true for UUID', () {
      final stream = toStream('e3ff1563-6977-4824-800a-be7118b22deb');
      expect(
          KiwiTokenStreamFlyweight.isStructuredLiteral(stream,
              enumKeywords: enumKeywords),
          isTrue);
    });

    test('returns true for enum keyword', () {
      final stream = toStream('GREEN');
      expect(
          KiwiTokenStreamFlyweight.isStructuredLiteral(stream,
              enumKeywords: enumKeywords),
          isTrue);
    });

    test('returns false for non-literal', () {
      final stream = toStream('unrecognized');
      expect(
          KiwiTokenStreamFlyweight.isStructuredLiteral(stream,
              enumKeywords: enumKeywords),
          isFalse);
    });
  });

  group('consumeStructuredLiteral', () {
    const enumKeywords = ['RED', 'GREEN', 'BLUE'];
    test('parses integer literal', () {
      final literal = KiwiTokenStreamFlyweight.consumeStructuredLiteral(
        toStream('123'),
        enumKeywords: enumKeywords,
      );
      expect(literal, isA<ParsedInteger>());
      expect((literal as ParsedInteger).value, 123);
    });

    test('parses float literal', () {
      final literal = KiwiTokenStreamFlyweight.consumeStructuredLiteral(
        toStream('3.14'),
        enumKeywords: enumKeywords,
      );
      expect(literal, isA<ParsedFloat>());
      expect((literal as ParsedFloat).value, 3.14);
    });

    test('parses UUID literal', () {
      final literal = KiwiTokenStreamFlyweight.consumeStructuredLiteral(
        toStream('e3ff1563-6977-4824-800a-be7118b22deb'),
        enumKeywords: enumKeywords,
      );
      expect(literal, isA<ParsedUuid>());
      expect((literal as ParsedUuid).value,
          'e3ff1563-6977-4824-800a-be7118b22deb');
    });

    test('parses enum keyword literal', () {
      final literal = KiwiTokenStreamFlyweight.consumeStructuredLiteral(
        toStream('RED'),
        enumKeywords: enumKeywords,
      );
      expect(literal, isA<ParsedEnum>());
      expect((literal as ParsedEnum).value, 'RED');
    });

    test('throws for invalid literal', () {
      expect(
        () => KiwiTokenStreamFlyweight.consumeStructuredLiteral(
          toStream('invalid'),
          enumKeywords: enumKeywords,
        ),
        throwsA(isA<KiwiWatermelonSemanticException>()),
      );
    });
  });

  group('consumeStructuredLiterals', () {
    const enumKeywords = ['RED', 'GREEN', 'BLUE'];
    test('parses multiple literals in stream', () {
      final stream =
          toStream('123 3.14 GREEN e3ff1563-6977-4824-800a-be7118b22deb');

      final result = KiwiTokenStreamFlyweight.consumeStructuredLiterals(
        stream,
        enumKeywords: enumKeywords,
      );

      expect(result.length, 4);
      expect(result[0], isA<ParsedInteger>());
      expect(result[1], isA<ParsedFloat>());
      expect(result[2], isA<ParsedEnum>());
      expect(result[3], isA<ParsedUuid>());
    });

    test('stops at first invalid token', () {
      final stream = toStream('123 GREEN STOP 456');

      final result = KiwiTokenStreamFlyweight.consumeStructuredLiterals(
        stream,
        enumKeywords: enumKeywords,
      );

      expect(result.length, 2);
      expect(result[0], isA<ParsedInteger>());
      expect(result[1], isA<ParsedEnum>());
    });

    test('returns empty list when no literals present', () {
      final stream = toStream('STOP');

      final result = KiwiTokenStreamFlyweight.consumeStructuredLiterals(
        stream,
        enumKeywords: enumKeywords,
      );

      expect(result, isEmpty);
    });
  });

  group('Asterisk', () {
    test('returns true when current token is an asterisk', () {
      final stream = toStream('*');
      final result = KiwiTokenStreamFlyweight.isAsterisk(stream);
      expect(result, isTrue);
    });

    test('returns false when current token is not an asterisk', () {
      final stream = toStream('x');
      final result = KiwiTokenStreamFlyweight.isAsterisk(stream);
      expect(result, isFalse);
    });

    test('consumes asterisk successfully', () {
      final stream = toStream('*');
      expect(() => KiwiTokenStreamFlyweight.consumeAsterisk(stream),
          returnsNormally);
      expect(stream.isAtEnd, isTrue);
    });

    test('consumeAsterisk throws if not asterisk', () {
      final stream = toStream('foo');
      expect(() => KiwiTokenStreamFlyweight.consumeAsterisk(stream),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });
  group('Pattern Key', () {
    test('parses single-segment pattern', () {
      final stream = toStream('env');
      final result = KiwiTokenStreamFlyweight.consumePatternKey(stream);
      expect(result, equals('env'));
    });

    test('parses key with one wildcard segment', () {
      final stream = toStream('env:*');
      final result = KiwiTokenStreamFlyweight.consumePatternKey(stream);
      expect(result, equals('env:*'));
    });

    test('parses full multi-segment key with wildcard at end', () {
      final stream = toStream('cache:views:*');
      final result = KiwiTokenStreamFlyweight.consumePatternKey(stream);
      expect(result, equals('cache:views:*'));
    });

    test('parses key with wildcard in the middle', () {
      final stream = toStream('env:*:color');
      final result = KiwiTokenStreamFlyweight.consumePatternKey(stream);
      expect(result, equals('env:*:color'));
    });

    test('throws if key is malformed (e.g., starts with colon)', () {
      final stream = toStream(':foo');
      expect(() => KiwiTokenStreamFlyweight.consumePatternKey(stream),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });

    test('throws if segment is not identifier or asterisk', () {
      final stream = toStream('env:123');
      expect(() => KiwiTokenStreamFlyweight.consumePatternKey(stream),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });
  group('consumePatternKeys', () {
    test('parses a single pattern key', () {
      final stream = toStream('env:users:*');
      final result = KiwiTokenStreamFlyweight.consumePatternKeys(stream);
      expect(result, equals(['env:users:*']));
    });

    test('parses multiple pattern keys', () {
      final stream = toStream('cache:views:* cache:users:*');
      final result = KiwiTokenStreamFlyweight.consumePatternKeys(stream);
      expect(result, equals(['cache:views:*', 'cache:users:*']));
    });

    test('parses pattern with wildcard in middle', () {
      final stream = toStream('env:*:shape');
      final result = KiwiTokenStreamFlyweight.consumePatternKeys(stream);
      expect(result, equals(['env:*:shape']));
    });

    test('parses patterns with only identifiers (no wildcards)', () {
      final stream = toStream('env:user:name env:user:email');
      final result = KiwiTokenStreamFlyweight.consumePatternKeys(stream);
      expect(result, equals(['env:user:name', 'env:user:email']));
    });

    test('parses patterns followed by number', () {
      final stream = toStream('env:user:name env:user:email 123');
      final result = KiwiTokenStreamFlyweight.consumePatternKeys(stream);
      expect(result, equals(['env:user:name', 'env:user:email']));
    });

    test('throws when trailing colon is not followed by segment', () {
      final stream = toStream('env:users:*:');
      expect(
        () => KiwiTokenStreamFlyweight.consumePatternKeys(stream),
        throwsA(isA<KiwiWatermelonSemanticException>()),
      );
    });

    test('throws when segment is numeric (invalid token)', () {
      final stream = toStream('env:123');
      expect(
        () => KiwiTokenStreamFlyweight.consumePatternKeys(stream),
        throwsA(isA<KiwiWatermelonSemanticException>()),
      );
    });
  });

  group('consumeCompositeVariables', () {
    test('parses a single composite variable', () {
      final stream = toStream('env:users:one');
      final result = KiwiTokenStreamFlyweight.consumeCompositeVariables(stream,
          options: storeOptions);
      expect(result, equals(['env:users:one']));
    });

    test('parses two composite variables', () {
      final stream = toStream('env:users:one env:users:two');
      final result = KiwiTokenStreamFlyweight.consumeCompositeVariables(stream,
          options: storeOptions);
      expect(result, equals(['env:users:one', 'env:users:two']));
    });

    test('parses two composite variables followed by number', () {
      final stream = toStream('env:users:one env:users:two 42');
      final result = KiwiTokenStreamFlyweight.consumeCompositeVariables(stream,
          options: storeOptions);
      expect(result, equals(['env:users:one', 'env:users:two']));
    });
  });
}
