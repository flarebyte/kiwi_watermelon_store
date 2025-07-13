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
  CommandTypes.INCR,
  CommandTypes.DECR,
  CommandTypes.INCRBY,
  CommandTypes.DECRBY,
  CommandTypes.INCRBYFLOAT,
  CommandTypes.INCRBYFLOAT
];

class KiwiCommandAnalyser {
  final KiwiWatermelonOptions options;

  KiwiCommandAnalyser({required this.options});

  KiwiWatermelonAction parseSingleCommand(KiwiWatermelonTokenStream stream) {
    if (!KiwiTokenStreamFlyweight.isAnyKeyword(stream, userCommands)) {
      throw KiwiWatermelonSemanticException(
          "Expected a command", stream.current);
    }
    ;

    final command = KiwiTokenStreamFlyweight.consumeIdentifier(stream);

    switch (command.text) {
      case CommandTypes.INCR:
        final key = KiwiTokenStreamFlyweight.consumeCompositeVariable(stream,
            options: options);
        return KiwiWatermelonActionFactory.incr(key);

      case CommandTypes.DECR:
        final key = KiwiTokenStreamFlyweight.consumeCompositeVariable(stream,
            options: options);
        return KiwiWatermelonActionFactory.decr(key);

      case CommandTypes.INCRBY:
        final key = KiwiTokenStreamFlyweight.consumeCompositeVariable(stream,
            options: options);

        final value = KiwiTokenStreamFlyweight.consumeInteger(stream);
        return KiwiWatermelonActionFactory.incrBy(key, value);

      case CommandTypes.DECRBY:
        final key = KiwiTokenStreamFlyweight.consumeCompositeVariable(stream,
            options: options);
        final value = KiwiTokenStreamFlyweight.consumeInteger(stream);
        return KiwiWatermelonActionFactory.decrBy(key, value);

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
