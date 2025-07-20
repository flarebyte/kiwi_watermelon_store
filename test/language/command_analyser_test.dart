import 'package:kiwi_watermelon_store/src/action/base_action.dart';
import 'package:kiwi_watermelon_store/src/action/del_action.dart';
import 'package:kiwi_watermelon_store/src/action/incr_action.dart';
import 'package:kiwi_watermelon_store/src/action/key_action.dart';
import 'package:kiwi_watermelon_store/src/action/list_action.dart';
import 'package:kiwi_watermelon_store/src/action/set_action.dart';
import 'package:kiwi_watermelon_store/src/action/sets_action.dart';
import 'package:kiwi_watermelon_store/src/language/command_analyser.dart';
import 'package:kiwi_watermelon_store/src/language/semantic_exception.dart';
import 'package:kiwi_watermelon_store/src/language/token_stream.dart';
import 'package:kiwi_watermelon_store/src/language/tokeniser.dart';
import 'package:test/test.dart';

import '../code_fixtures.dart';

void main() {
  final tokeniser = KiwiWatermelonTokeniser();
  final KiwiCommandAnalyser analyser =
      KiwiCommandAnalyser(options: storeOptions, role: a_team);
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

  group('SET analyser', () {
    test('parse SET integer', () {
      final action = parseSingleCommand('SET env:budget 10');
      expect(action, isA<KiwiSetIntegerAction>());
    });

    test('parse SET float', () {
      final action = parseSingleCommand('SET env:budget 10.7');
      expect(action, isA<KiwiSetFloatAction>());
    });

    test('parse SET UUID', () {
      final action = parseSingleCommand(
          'SET env:event:london e3ff1563-6977-4824-800a-be7118b22deb');
      expect(action, isA<KiwiSetUuidAction>());
    });

    test('parse SET enum', () {
      final action = parseSingleCommand('SET env:report true');
      expect(action, isA<KiwiSetEnumAction>());
    });

    test('throws SemanticException on malformed parameter', () {
      expect(() => parseSingleCommand('SET env:budget unknown'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('SADD analyser', () {
    test('parses SADD with valid UUIDs', () {
      final action = parseSingleCommand(
        'SADD env:users:roles:admin 660cba17-a6f4-43d3-bf5f-ebc359c69e9c 9a7256a7-5268-4fe3-b5fc-bf27a105a8ba',
      );
      expect(action, isA<KiwiSAddAction>());
    });

    test('throws on missing members', () {
      expect(() => parseSingleCommand('SADD env:users:roles:admin'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });
  group('SREM analyser', () {
    test('parses SREM with integers', () {
      final action = parseSingleCommand('SREM env:users:roles:guest 1 2 3');
      expect(action, isA<KiwiSRemAction>());
    });

    test('throws on missing members', () {
      expect(() => parseSingleCommand('SREM env:users:roles:guest'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('LPUSH analyser', () {
    test('parses LPUSH with mixed literals', () {
      final action = parseSingleCommand(
          'LPUSH env:queue:jobs:pending 123 75df7c47-4599-4cfb-8443-5f4546c743db 42.5');
      expect(action, isA<LPushAction>());
    });

    test('throws on missing values', () {
      expect(() => parseSingleCommand('LPUSH env:queue:jobs:pending'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });
  group('RPUSH analyser', () {
    test('parses RPUSH with valid numbers', () {
      final action = parseSingleCommand('RPUSH env:queue:jobs:complete 1 2');
      expect(action, isA<KiwiRPushAction>());
    });

    test('throws on missing values', () {
      expect(() => parseSingleCommand('RPUSH env:queue:jobs:complete'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('SMOVE analyser', () {
    test('parses SMOVE with valid UUID', () {
      final action = parseSingleCommand(
        'SMOVE env:users:roles:temp env:users:roles:active a15838ce-e8d8-4374-b862-b8fdf611fa5a',
      );
      expect(action, isA<KiwiSMoveAction>());
    });

    test('throws on missing member', () {
      expect(() => parseSingleCommand('SMOVE env:src env:dest'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('LREM analyser', () {
    test('parses LREM with UUID and count', () {
      final action = parseSingleCommand(
        'LREM env:queue:jobs:failed 2 fead3654-abe1-4719-b89c-b837440ec16d',
      );
      expect(action, isA<KiwiLRemAction>());
    });

    test('throws on missing value', () {
      expect(() => parseSingleCommand('LREM env:queue:jobs:failed 2'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });

    test('throws on missing count', () {
      expect(() => parseSingleCommand('LREM env:queue:jobs:failed'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('RPOPLPUSH analyser', () {
    test('parses RPOPLPUSH with source and destination', () {
      final action =
          parseSingleCommand('RPOPLPUSH env:queue:active env:queue:retry');
      expect(action, isA<KiwiRPopLPushAction>());
    });

    test('throws on missing destination', () {
      expect(() => parseSingleCommand('RPOPLPUSH env:queue:active'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('LMOVE analyser', () {
    test('parses LMOVE with direction', () {
      final action =
          parseSingleCommand('LMOVE env:queue:one env:queue:two LEFT RIGHT');
      expect(action, isA<KiwiLMoveAction>());
    });

    test('throws on missing direction', () {
      expect(() => parseSingleCommand('LMOVE env:queue:one env:queue:two LEFT'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });
  group('RENAME analyser', () {
    test('parses RENAME with old and new keys', () {
      final action = parseSingleCommand('RENAME env:key:one env:key:two');
      expect(action, isA<KiwiRenameAction>());
    });

    test('throws on missing new key', () {
      expect(() => parseSingleCommand('RENAME env:key:one'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('RENAMENX analyser', () {
    test('parses RENAMENX with old and new keys', () {
      final action = parseSingleCommand('RENAMENX env:tmp:a env:tmp:b');
      expect(action, isA<KiwiRenameNXAction>());
    });

    test('throws on missing new key', () {
      expect(() => parseSingleCommand('RENAMENX env:tmp:a'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('DEL analyser', () {
    test('parses DEL with one key', () {
      final action = parseSingleCommand('DEL env:user:123:name');
      expect(action, isA<KiwiDelAction>());
    });

    test('parses DEL with multiple keys', () {
      final action =
          parseSingleCommand('DEL env:user:123:name env:user:456:age');
      expect(action, isA<KiwiDelAction>());
      expect((action as KiwiDelAction).keys.length, 2);
    });

    test('throws on empty input', () {
      expect(() => parseSingleCommand('DEL'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });

  group('DELKEYS analyser', () {
    test('parses DELKEYS with one pattern', () {
      final action = parseSingleCommand('DELKEYS env:user:*');
      expect(action, isA<KiwiDelKeysAction>());
    });

    test('parses DELKEYS with multiple patterns', () {
      final action = parseSingleCommand('DELKEYS env:user:* env:order:*');
      expect(action, isA<KiwiDelKeysAction>());
      expect((action as KiwiDelKeysAction).patterns.length, 2);
    });

    test('throws on empty input', () {
      expect(() => parseSingleCommand('DELKEYS'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });
  group('FLUSHDB analyser', () {
    test('parses FLUSHDB with no arguments', () {
      final action = parseSingleCommand('FLUSHDB');
      expect(action, isA<KiwiFlushDbAction>());
    });

    test('throws if FLUSHDB is followed by arguments', () {
      expect(() => parseSingleCommand('FLUSHDB something'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });
}
