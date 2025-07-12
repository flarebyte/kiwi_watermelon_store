import 'package:kiwi_watermelon_store/src/language/token_stream_flyweight.dart';

import '../action/action_factory.dart';
import '../action/base_action.dart';
import '../store/manager_options.dart';
import 'semantic_exception.dart';
import 'token_stream.dart';

class CommandTypes {
  static const String INCR = 'INCR';
  static const String DECR = 'DECR';
  static const String INCRBY = 'INCRBY';
  static const String DECRBY = 'DECRBY';
  static const String INCRBYFLOAT = 'INCRBYFLOAT';
  static const String DECRBYFLOAT = 'DECRBYFLOAT';
}

const List<String> userCommands = [
  'INCR',
  'DECR',
  'INCRBY',
  'DECRBY',
  'INCRBYFLOAT',
  'DECRBYFLOAT'
];

class KiwiCommandAnalyzer {
  final KiwiWatermelonOptions options;

  KiwiCommandAnalyzer({required this.options});

  KiwiWatermelonAction parseSingleCommand(KiwiWatermelonTokenStream stream) {
    if (!KiwiTokenStreamFlyweight.isAnyKeyword(stream, userCommands)) {
      throw KiwiWatermelonSemanticException(
          "Expected a command", stream.current);
    }
    ;

    final command = KiwiTokenStreamFlyweight.consumeIdentifier(stream);

    switch (command.text) {
      case CommandTypes.INCR:
        final keyToken = KiwiTokenStreamFlyweight.consumeIdentifier(stream);
        return KiwiWatermelonActionFactory.incr(keyToken.text);

      // case 'DECR':
      //   final keyToken =
      //       KiwiWatermelonTokenStreamFlyweight.consumeIdentifier(stream);
      //   return KiwiWatermelonActionFactory.decr(keyToken.text);

      // case 'INCRBY':
      //   final keyToken =
      //       KiwiWatermelonTokenStreamFlyweight.consumeIdentifier(stream);
      //   final valueToken = stream.consume();
      //   final value = int.tryParse(valueToken?.text ?? '');
      //   if (value == null) {
      //     throw SemanticException(
      //       'Expected integer after key for INCRBY',
      //       valueToken?.startPosition,
      //       valueToken?.startIndex ?? -1,
      //     );
      //   }
      //   return KiwiWatermelonActionFactory.incrBy(keyToken.text, value);

      // case 'DECRBY':
      //   final keyToken =
      //       KiwiWatermelonTokenStreamFlyweight.consumeIdentifier(stream);
      //   final valueToken = stream.consume();
      //   final value = int.tryParse(valueToken?.text ?? '');
      //   if (value == null) {
      //     throw SemanticException(
      //       'Expected integer after key for DECRBY',
      //       valueToken?.startPosition,
      //       valueToken?.startIndex ?? -1,
      //     );
      //   }
      //   return KiwiWatermelonActionFactory.decrBy(keyToken.text, value);

      // case 'INCRBYFLOAT':
      //   final keyToken =
      //       KiwiWatermelonTokenStreamFlyweight.consumeIdentifier(stream);
      //   final valueToken = stream.consume();
      //   final value = double.tryParse(valueToken?.text ?? '');
      //   if (value == null) {
      //     throw SemanticException(
      //       'Expected float after key for INCRBYFLOAT',
      //       valueToken?.startPosition,
      //       valueToken?.startIndex ?? -1,
      //     );
      //   }
      //   return KiwiWatermelonActionFactory.incrByFloat(keyToken.text, value);

      // case 'DECRBYFLOAT':
      //   final keyToken =
      //       KiwiWatermelonTokenStreamFlyweight.consumeIdentifier(stream);
      //   final valueToken = stream.consume();
      //   final value = double.tryParse(valueToken?.text ?? '');
      //   if (value == null) {
      //     throw SemanticException(
      //       'Expected float after key for DECRBYFLOAT',
      //       valueToken?.startPosition,
      //       valueToken?.startIndex ?? -1,
      //     );
      //   }
      //   return KiwiWatermelonActionFactory.decrByFloat(keyToken.text, value);

      default:
        throw KiwiWatermelonSemanticException(
            "Unexpected command", stream.current);
    }
  }
}
