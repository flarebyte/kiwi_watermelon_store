
import 'package:kiwi_watermelon_store/src/language/tokeniser.dart';
import 'package:test/test.dart';

import '../code_fixtures.dart';
void main() {
  group('RhapsodyTokeniser', () {
    final tokeniser = KiwiWatermelonTokeniser();
    final maker = QuickQueryMaker(prefix: 'env'); 

    test('parses a simple function call with a prefixed variable', () {
      final code = maker.setNum('metrics/cpu/load', 0.75);

      final tokens = tokeniser.parse(code);
      expect(tokens, isNotEmpty);

      expect(tokens.length, equals(6));

      expect(tokens[0].text, equals('func1_a'));
      expect(tokens[0].type, equals(TokenTypes.identifier));

      expect(tokens[1].text, equals('('));
      expect(tokens[1].type, equals(TokenTypes.lparen));

    });


  });
}
