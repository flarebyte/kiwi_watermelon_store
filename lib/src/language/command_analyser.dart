import 'package:kiwi_watermelon_store/src/language/token_stream_flyweight.dart';

import '../action/action_access.dart';
import '../action/action_factory.dart';
import '../action/base_action.dart';
import '../store/manager_options.dart';
import 'semantic_exception.dart';
import 'token.dart';
import 'token_stream.dart';

class CommandTypes {
  static const String INCR = 'INCR';
  static const String DECR = 'DECR';
  static const String INCRBY = 'INCRBY';
  static const String DECRBY = 'DECRBY';
  static const String INCRBYFLOAT = 'INCRBYFLOAT';
  static const String DECRBYFLOAT = 'DECRBYFLOAT';
  static const String SET = 'SET';

  // List commands
  static const String LPUSH = 'LPUSH';
  static const String RPUSH = 'RPUSH';
  static const String LREM = 'LREM';
  static const String LTRIM = 'LTRIM';
  static const String RPOPLPUSH = 'RPOPLPUSH';
  static const String LMOVE = 'LMOVE';

  // Set commands
  static const String SADD = 'SADD';
  static const String SREM = 'SREM';
  static const String SMOVE = 'SMOVE';

  // Key commands
  static const String RENAME = 'RENAME';
  static const String RENAMENX = 'RENAMENX';
}

const List<String> userCommands = [
  CommandTypes.INCR,
  CommandTypes.DECR,
  CommandTypes.INCRBY,
  CommandTypes.DECRBY,
  CommandTypes.INCRBYFLOAT,
  CommandTypes.DECRBYFLOAT,
  CommandTypes.SET,
  CommandTypes.LPUSH,
  CommandTypes.RPUSH,
  CommandTypes.LREM,
  CommandTypes.LTRIM,
  CommandTypes.RPOPLPUSH,
  CommandTypes.LMOVE,
  CommandTypes.SADD,
  CommandTypes.SREM,
  CommandTypes.SMOVE,
  CommandTypes.RENAME,
  CommandTypes.RENAMENX,
];

/// Interprets command streams into executable actions based on role and authorization policy.
class KiwiCommandAnalyser {
  final KiwiWatermelonOptions options;
  final String role;
  late final KiwiWatermelonActionAccess access;

  /// Creates a command analyser for the given [role] and [options].
  KiwiCommandAnalyser({
    required this.options,
    required this.role,
  }) {
    access = KiwiWatermelonActionAccess(capabilities: options.capabilities);
  }

  /// Parses a single command from the [stream] and returns a corresponding action.
  ///
  /// Performs authorization checks and throws [KiwiWatermelonAccessException] if the role is not allowed.
  KiwiWatermelonAction parseSingleCommand(KiwiWatermelonTokenStream stream) {
    if (!KiwiTokenStreamFlyweight.isAnyKeyword(stream, userCommands)) {
      throw KiwiWatermelonSemanticException(
          "Expected a command", stream.current);
    }

    final command = KiwiTokenStreamFlyweight.consumeIdentifier(stream);

    switch (command.text) {
      case CommandTypes.INCR:
        {
          final key = _compositeKey(stream);
          _assert(access.incr(key, role: role), command, key);
          return KiwiWatermelonActionFactory.incr(key);
        }

      case CommandTypes.DECR:
        {
          final key = _compositeKey(stream);
          _assert(access.decr(key, role: role), command, key);
          return KiwiWatermelonActionFactory.decr(key);
        }

      case CommandTypes.INCRBY:
        {
          final key = _compositeKey(stream);
          final value = KiwiTokenStreamFlyweight.consumeInteger(stream);
          _assert(access.incrBy(key, role: role), command, key);
          return KiwiWatermelonActionFactory.incrBy(key, value);
        }

      case CommandTypes.DECRBY:
        {
          final key = _compositeKey(stream);
          final value = KiwiTokenStreamFlyweight.consumeInteger(stream);
          _assert(access.decrBy(key, role: role), command, key);
          return KiwiWatermelonActionFactory.decrBy(key, value);
        }

      case CommandTypes.INCRBYFLOAT:
        {
          final key = _compositeKey(stream);
          final value = KiwiTokenStreamFlyweight.consumeDouble(stream);
          _assert(access.incrByFloat(key, role: role), command, key);
          return KiwiWatermelonActionFactory.incrByFloat(key, value);
        }

      case CommandTypes.DECRBYFLOAT:
        {
          final key = _compositeKey(stream);
          final value = KiwiTokenStreamFlyweight.consumeDouble(stream);
          _assert(access.decrByFloat(key, role: role), command, key);
          return KiwiWatermelonActionFactory.decrByFloat(key, value);
        }

      case CommandTypes.SET:
        {
          final key = _compositeKey(stream);
          final parsed = KiwiTokenStreamFlyweight.consumeStructuredLiteral(
            stream,
            enumKeywords: options.getEnums(),
          );

          switch (parsed) {
            case ParsedInteger(:final value):
              _assert(access.setInteger(key, role: role), command, key);
              return KiwiWatermelonActionFactory.setInteger(key, value);
            case ParsedFloat(:final value):
              _assert(access.setDouble(key, role: role), command, key);
              return KiwiWatermelonActionFactory.setDouble(key, value);
            case ParsedUuid(:final value):
              _assert(access.setUuid(key, role: role), command, key);
              return KiwiWatermelonActionFactory.setUuid(key, value,
                  validate: false);
            case ParsedEnum(:final value):
              _assert(access.setEnum(key, role: role), command, key);
              return KiwiWatermelonActionFactory.setEnum(key, value,
                  options: options, validate: false);
          }
        }

      // ---------- LIST COMMANDS ----------
      case CommandTypes.LPUSH:
        {
          final key = _compositeKey(stream);
          final firstLiteral =
              KiwiTokenStreamFlyweight.consumeStructuredLiteral(stream,
                  enumKeywords: options.getEnums());

          final literals = KiwiTokenStreamFlyweight.consumeStructuredLiterals(
            stream,
            enumKeywords: options.getEnums(),
          );
          final values =
              [firstLiteral, ...literals].map((l) => l.asString).toList();

          _assert(access.lpush(key, role: role), command, key);

          return KiwiWatermelonActionFactory.lpush(key, values, separator: ',');
        }

      case CommandTypes.RPUSH:
        {
          final key = _compositeKey(stream);
          final firstLiteral =
              KiwiTokenStreamFlyweight.consumeStructuredLiteral(stream,
                  enumKeywords: options.getEnums());

          final literals = KiwiTokenStreamFlyweight.consumeStructuredLiterals(
            stream,
            enumKeywords: options.getEnums(),
          );
          final values =
              [firstLiteral, ...literals].map((l) => l.asString).toList();

          _assert(access.rpush(key, role: role), command, key);

          return KiwiWatermelonActionFactory.rpush(key, values, separator: ',');
        }

      case CommandTypes.LREM:
        {
          final key = _compositeKey(stream);
          final count = KiwiTokenStreamFlyweight.consumeInteger(stream);

          final literal = KiwiTokenStreamFlyweight.consumeStructuredLiteral(
            stream,
            enumKeywords: options.getEnums(),
          );
          final value = literal.asString;

          _assert(access.lrem(key, role: role), command, key);

          return KiwiWatermelonActionFactory.lrem(
            key,
            count,
            value,
            separator: ',',
          );
        }

      case CommandTypes.LTRIM:
        {
          final key = _compositeKey(stream);
          final start = KiwiTokenStreamFlyweight.consumeInteger(stream);
          final stop = KiwiTokenStreamFlyweight.consumeInteger(stream);
          _assert(access.ltrim(key, role: role), command, key);
          return KiwiWatermelonActionFactory.ltrim(key, start, stop,
              separator: ',');
        }

      case CommandTypes.RPOPLPUSH:
        {
          final source = _compositeKey(stream);
          final dest = _compositeKey(stream);
          _assert(access.rpoplpush(source, dest, role: role), command, source,
              [dest]);
          return KiwiWatermelonActionFactory.rpoplpush(source, dest,
              separator: ',');
        }

      case CommandTypes.LMOVE:
        {
          final source = _compositeKey(stream);
          final dest = _compositeKey(stream);
          final from = KiwiTokenStreamFlyweight.consumeIdentifier(stream).text;
          final to = KiwiTokenStreamFlyweight.consumeIdentifier(stream).text;
          _assert(
              access.lmove(source, dest, role: role), command, source, [dest]);
          return KiwiWatermelonActionFactory.lmove(source, dest, from, to,
              separator: ',');
        }

      // ---------- SET COMMANDS ----------
      case CommandTypes.SADD:
        {
          final key = _compositeKey(stream);
          final firstLiteral =
              KiwiTokenStreamFlyweight.consumeStructuredLiteral(stream,
                  enumKeywords: options.getEnums());

          final literals = KiwiTokenStreamFlyweight.consumeStructuredLiterals(
            stream,
            enumKeywords: options.getEnums(),
          );

          _assert(access.sadd(key, role: role), command, key);

          return KiwiWatermelonActionFactory.sadd(
            key,
            ([firstLiteral, ...literals]).map((l) => l.asString).toList(),
            separator: ',', // this is still internal to Redis-style encoding
          );
        }

      case CommandTypes.SREM:
        {
          final key = _compositeKey(stream);

          final firstLiteral =
              KiwiTokenStreamFlyweight.consumeStructuredLiteral(stream,
                  enumKeywords: options.getEnums());
          final literals = KiwiTokenStreamFlyweight.consumeStructuredLiterals(
            stream,
            enumKeywords: options.getEnums(),
          );
          final members =
              [firstLiteral, ...literals].map((l) => l.asString).toList();

          _assert(access.srem(key, role: role), command, key);

          return KiwiWatermelonActionFactory.srem(key, members, separator: ',');
        }

      case CommandTypes.SMOVE:
        {
          final source = _compositeKey(stream);
          final dest = _compositeKey(stream);
          final parsed = KiwiTokenStreamFlyweight.consumeStructuredLiteral(
            stream,
            enumKeywords: options.getEnums(),
          );
          final member = parsed.asString;
          _assert(
              access.smove(source, dest, role: role), command, source, [dest]);
          return KiwiWatermelonActionFactory.smove(source, dest, member,
              separator: ',');
        }

      // ---------- KEY COMMANDS ----------
      case CommandTypes.RENAME:
        {
          final oldKey = _compositeKey(stream);
          final newKey = _compositeKey(stream);
          _assert(access.rename(oldKey, newKey, role: role), command, oldKey,
              [newKey]);
          return KiwiWatermelonActionFactory.rename(oldKey, newKey);
        }

      case CommandTypes.RENAMENX:
        {
          final oldKey = _compositeKey(stream);
          final newKey = _compositeKey(stream);
          _assert(access.renamenx(oldKey, newKey, role: role), command, oldKey,
              [newKey]);
          return KiwiWatermelonActionFactory.renamenx(oldKey, newKey);
        }

      default:
        throw KiwiWatermelonSemanticException(
            "Unknown command: ${command.text}", stream.current);
    }
  }

  /// Helper to check access and throw a standard access exception.
  void _assert(bool allowed, KiwiWatermelonToken command, String key,
      [List<String> others = const []]) {
    if (!allowed) {
      throw KiwiWatermelonAccessException(
        role: role,
        command: command.text,
        key: key,
        otherKeys: others,
        token: command,
      );
    }
  }

  /// Parses a composite key based on domain conventions and token stream.
  String _compositeKey(KiwiWatermelonTokenStream stream) {
    return KiwiTokenStreamFlyweight.consumeCompositeVariable(stream,
        options: options);
  }
}
