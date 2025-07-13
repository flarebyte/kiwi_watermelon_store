import 'package:kiwi_watermelon_store/src/action/base_action.dart';
import 'package:kiwi_watermelon_store/src/action/incr_action.dart';
import 'package:kiwi_watermelon_store/src/language/command_analyser.dart';
import 'package:kiwi_watermelon_store/src/language/semantic_exception.dart';
import 'package:kiwi_watermelon_store/src/language/token_stream.dart';
import 'package:kiwi_watermelon_store/src/language/tokeniser.dart';
import 'package:test/test.dart';

import '../code_fixtures.dart';

void main() {
  final tokeniser = KiwiWatermelonTokeniser();
  final KiwiCommandAnalyser analyser =
      KiwiCommandAnalyser(options: storeOptions);
  KiwiWatermelonAction parseSingleCommand(String code) {
    final tokens = tokeniser.parse(code);
    final tokenStream = KiwiWatermelonTokenStream(tokens);
    return analyser.parseSingleCommand(tokenStream);
  }

  group('INCR analyser', () {
    test('parse INCR', () {
      final action = parseSingleCommand(
          'INCR env:metrics:api:total:color:blue:status:ready');
      expect(action, isA<KiwiIncrAction>());
    });

    test('throws SemanticException when incorrect', () {
      expect(() => parseSingleCommand('INCR 12'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('DECR analyser', () {
    test('parse DECR', () {
      final action = parseSingleCommand('DECR env:retries');
      expect(action, isA<KiwiDecrAction>());
    });

    test('throws SemanticException on invalid key', () {
      expect(() => parseSingleCommand('DECR ,'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('INCRBY analyser', () {
    test('parse INCRBY', () {
      final action = parseSingleCommand('INCRBY env:views 10');
      expect(action, isA<KiwiIncrByAction>());
    });

    test('throws SemanticException on non-integer', () {
      expect(() => parseSingleCommand('INCRBY env:views ten'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('DECRBY analyser', () {
    test('parse DECRBY', () {
      final action = parseSingleCommand('DECRBY env:count 5');
      expect(action, isA<KiwiDecrByAction>());
    });

    test('throws SemanticException on missing value', () {
      expect(() => parseSingleCommand('DECRBY env:count'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('INCRBYFLOAT analyser', () {
    test('parse INCRBYFLOAT', () {
      final action = parseSingleCommand('INCRBYFLOAT env:price 3.14');
      expect(action, isA<KiwiIncrByFloatAction>());
    });

    test('throws SemanticException on non-float', () {
      expect(() => parseSingleCommand('INCRBYFLOAT env:price free'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('DECRBYFLOAT analyser', () {
    test('parse DECRBYFLOAT', () {
      final action = parseSingleCommand('DECRBYFLOAT env:budget 1.25');
      expect(action, isA<KiwiDecrByFloatAction>());
    });

    test('throws SemanticException on malformed number', () {
      expect(() => parseSingleCommand('DECRBYFLOAT env:budget --1.0'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });
}
