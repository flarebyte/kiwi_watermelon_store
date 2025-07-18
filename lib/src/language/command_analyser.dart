import 'package:kiwi_watermelon_store/src/language/token_stream_flyweight.dart';

import '../action/action_access.dart';
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
  static const String SET = 'SET';
}

const List<String> userCommands = [
  CommandTypes.INCR,
  CommandTypes.DECR,
  CommandTypes.INCRBY,
  CommandTypes.DECRBY,
  CommandTypes.INCRBYFLOAT,
  CommandTypes.DECRBYFLOAT,
  CommandTypes.SET,
];

class KiwiCommandAnalyser {
  final KiwiWatermelonOptions options;
  final String role;
  late KiwiWatermelonActionAccess access;

  KiwiCommandAnalyser({required this.options, required this.role}) {
    access = KiwiWatermelonActionAccess(capabilities: options.capabilities);
  }

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
        if (!access.incr(key, role: role)) {
          throw KiwiWatermelonSemanticException(
              'Access denied for $role attempting to incr $key',
              stream.current);
        }
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

      case CommandTypes.INCRBYFLOAT:
        final key = KiwiTokenStreamFlyweight.consumeCompositeVariable(stream,
            options: options);
        final value = KiwiTokenStreamFlyweight.consumeDouble(stream);
        return KiwiWatermelonActionFactory.incrByFloat(key, value);

      case CommandTypes.DECRBYFLOAT:
        final key = KiwiTokenStreamFlyweight.consumeCompositeVariable(stream,
            options: options);
        final value = KiwiTokenStreamFlyweight.consumeDouble(stream);
        return KiwiWatermelonActionFactory.decrByFloat(key, value);

      case CommandTypes.SET:
        final key = KiwiTokenStreamFlyweight.consumeCompositeVariable(stream,
            options: options);
        if (KiwiTokenStreamFlyweight.isNumber(stream)) {
          final value = KiwiTokenStreamFlyweight.consumeInteger(stream);
          return KiwiWatermelonActionFactory.setInteger(key, value);
        }

        if (KiwiTokenStreamFlyweight.isFloat(stream)) {
          final value = KiwiTokenStreamFlyweight.consumeDouble(stream);
          return KiwiWatermelonActionFactory.setDouble(key, value);
        }

        if (KiwiTokenStreamFlyweight.isUuid(stream)) {
          final value = KiwiTokenStreamFlyweight.consumeUuid(stream);
          return KiwiWatermelonActionFactory.setUuid(key, value,
              validate: false);
        }

        if (KiwiTokenStreamFlyweight.isAnyKeyword(stream, options.getEnums())) {
          final value = KiwiTokenStreamFlyweight.consumeIdentifier(stream);
          return KiwiWatermelonActionFactory.setEnum(key, value.text,
              options: options, validate: false);
        }
        throw KiwiWatermelonSemanticException(
            "Unexpected int, float, UUID or enum as value fr SET",
            stream.current);

      default:
        throw KiwiWatermelonSemanticException(
            "Unexpected command", stream.current);
    }
  }
}
