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
    
    test('should parse command', () {
      final action = parseSingleCommand('INCR env:metrics:api:total:color:blue:status:ready');
      expect(action,  isA<KiwiIncrAction>());
    });

     test('throws SemanticException when incorrect', () {
      expect(
          () => parseSingleCommand('INCR 12'),
          throwsA(isA<KiwiWatermelonSemanticException>()));
    });
  });
}
