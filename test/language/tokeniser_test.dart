import 'package:test/test.dart';
import 'package:kiwi_watermelon_store/src/language/tokeniser.dart';

import '../code_fixtures.dart';

void main() {
  final tokeniser = KiwiWatermelonTokeniser();

  group('RhapsodyTokeniser command coverage', () {
    print(validCommands.join('\n'));
    for (final command in validCommands) {
      test('tokenises command: $command', () {
        final tokens = tokeniser.parse(command);

        expect(tokens, isNotEmpty);
        expect(tokens.first.type, equals(TokenTypes.identifier));
        expect(tokens.first.text, isNotEmpty);

        for (final token in tokens) {
          expect(token.type, isNot(TokenTypes.unknown),
              reason: 'Unknown token detected: ${token.text}');
        }
      });
    }
  });
}
