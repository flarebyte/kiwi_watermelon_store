import 'package:kiwi_watermelon_store/src/language/syntax_analyser.dart';
import 'package:kiwi_watermelon_store/src/language/tokeniser.dart';
import 'package:test/test.dart';

import '../code_fixtures.dart';

void main() {
  group('KiwiWatermelonSyntaxAnalyzer', () {
    final tokeniser = KiwiWatermelonTokeniser();
    final KiwiWatermelonSyntaxAnalyzer analyser =
        KiwiWatermelonSyntaxAnalyzer(options: storeOptions, role: a_team);
    test('should analyse ', () {
      final tokens = tokeniser.parse([
        'INCR env:metrics:api:total:color:blue:status:ready',
        'DECR env:tries'
      ].join(';\n'));
      final analysed = analyser.analyse(tokens);
      expect(analysed.failure, null);
      expect(analysed.actions.length, 2);
    });
  });
}
