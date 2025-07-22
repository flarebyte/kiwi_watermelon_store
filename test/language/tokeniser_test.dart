import 'package:test/test.dart';
import 'package:kiwi_watermelon_store/src/language/tokeniser.dart';

import '../code_fixtures.dart';
import '../fixture_helper.dart';

void main() async {
  final tokeniser = KiwiWatermelonTokeniser();
  final store = FixtureStore<TokenInfo>(
    filePath: 'test/__fixtures__/tokens.json',
    converter: TokenInfoConverter(),
  );

  Map<String, TokenInfo> tokenInfos = await store.load();
  ;

  group('Tokeniser command coverage', () {
    for (final command in validCommands) {
      test('tokenises command: $command', () async {
        final tokens = tokeniser.parse(command);

        expect(tokens, isNotEmpty);
        expect(tokens.first.type, equals(TokenTypes.identifier));
        expect(tokens.first.text, isNotEmpty);

        for (final token in tokens) {
          expect(token.type, isNot(TokenTypes.unknown),
              reason: 'Unknown token detected: ${token.text}');
        }
        final tokenTypes = tokens.map((token) => token.type).toList();
        final tokentexts = tokens.map((token) => token.text).toList();
        final expected = tokenInfos[command];
        // tokenInfos[command] =
        //     TokenInfo(code: command, types: tokenTypes, texts: tokentexts);
        // await store.save(tokenInfos);
        expect(tokenTypes, equals(expected?.types));
        expect(tokentexts, equals(expected?.texts));
      });
    }
  });
}
