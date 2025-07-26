import '../action/action_access.dart';
import '../action/read_action_factory.dart';
import '../select/select_base_action.dart';
import '../store/manager_options.dart';
import 'semantic_exception.dart';
import 'token.dart';
import 'token_stream.dart';
import 'token_stream_flyweight.dart';

class ReadCommandTypes {
  static const String GET = 'GET';
}

const List<String> readUserCommands = [
  ReadCommandTypes.GET,
];

/// Interprets command streams into executable actions based on role and authorization policy.
class KiwiReadCommandAnalyser {
  final KiwiWatermelonOptions options;
  final String role;
  late final KiwiWatermelonActionAccess access;

  /// Creates a command analyser for the given [role] and [options].
  KiwiReadCommandAnalyser({
    required this.options,
    required this.role,
  }) {
    access = KiwiWatermelonActionAccess(capabilities: options.capabilities);
  }

  /// Parses a single command from the [stream] and returns a corresponding action.
  ///
  /// Performs authorization checks and throws [KiwiWatermelonAccessException] if the role is not allowed.
  KiwiWatermelonSelectQuery<String> parseSingleCommand(
      KiwiWatermelonTokenStream stream) {
    if (!KiwiTokenStreamFlyweight.isAnyKeyword(stream, readUserCommands)) {
      throw KiwiWatermelonSemanticException(
          "Expected a command", stream.current);
    }

    final command = KiwiTokenStreamFlyweight.consumeIdentifier(stream);
    switch (command.text) {
      case ReadCommandTypes.GET:
        {
          final key = KiwiTokenStreamFlyweight.consumeCompositeVariable(stream,
              options: options);
          _assert(access.get(key, role: role), command, key);
          return KiwiWatermelonReadActionFactory.get(key);
        }
      default:
        throw KiwiWatermelonSemanticException(
            "Unknown read command: ${command.text}", stream.current);
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
}
