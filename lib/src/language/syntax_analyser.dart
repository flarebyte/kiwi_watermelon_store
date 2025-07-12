import 'package:kiwi_watermelon_store/src/language/token.dart';

import '../action/action_factory.dart';
import '../action/base_action.dart';
import '../store/manager_options.dart';
import 'analysis_failure.dart';
import 'tokeniser.dart';

class KiwiWatermelonSyntaxAnalysis {
  final KiwiWatermelonAnalysisFailure? failure;
  final List<KiwiWatermelonAction> actions;

  KiwiWatermelonSyntaxAnalysis({required this.actions, this.failure});

  bool isValid() {
    final invalid = failure != null;
    return !invalid;
  }
}

class KiwiWatermelonSyntaxAnalyzer {
  final KiwiWatermelonOptions options;

  KiwiWatermelonSyntaxAnalyzer({required this.options});

  KiwiWatermelonSyntaxAnalysis _success(List<KiwiWatermelonAction> actions) {
    return KiwiWatermelonSyntaxAnalysis(actions: actions);
  }

  KiwiWatermelonSyntaxAnalysis _failure(KiwiWatermelonAnalysisFailure failure) {
    return KiwiWatermelonSyntaxAnalysis(actions: [], failure: failure);
  }

  KiwiWatermelonSyntaxAnalysis analyse(List<KiwiWatermelonToken> tokens) {
    final actions = <KiwiWatermelonAction>[];
    final current = <KiwiWatermelonToken>[];

    for (final token in tokens) {
      if (token.type == TokenTypes.comment ||
          token.type == TokenTypes.unknown) {
        continue;
      }

      if (token.type == TokenTypes.semicolon) {
        if (current.isNotEmpty) {
          final action = _parseCommand(current);
          if (action == null) {
            return _failure(KiwiWatermelonAnalysisFailure(
              message:
                  'Invalid command: ${current.map((t) => t.text).join(" ")}',
              position: token.startPosition,
              index: token.startIndex,
              errorType: "Syntax Analysis Error",
              contextCode: token.text,
              expected: "",
              suggestion: "Check command syntax near '${token.text}'.",
            ));
          }
          actions.add(action);
          current.clear();
        }
        continue;
      }

      current.add(token);
    }

    // handle last command (if no trailing semicolon)
    if (current.isNotEmpty) {
      final action = _parseCommand(current);
      if (action == null) {
        return _failure(KiwiWatermelonAnalysisFailure(
          message: 'Invalid command: ${current.map((t) => t.text).join(" ")}',
          position: current[0].startPosition,
          index: current[0].startIndex,
          errorType: "Syntax Analysis Error",
          contextCode: current[0].text,
          expected: "",
          suggestion: "Check command syntax near '${current[0].text}'.",
        ));
      }
      actions.add(action);
    }

    return _success(actions);
  }

  KiwiWatermelonAction? _parseCommand(List<KiwiWatermelonToken> tokens) {
    if (tokens.isEmpty) return null;
    final cmd = tokens[0].text.toUpperCase();

    switch (cmd) {
      case 'INCR':
        if (tokens.length == 2 && tokens[1].type == TokenTypes.identifier) {
          return KiwiWatermelonActionFactory.incr(tokens[1].text);
        }
        break;
      case 'DECR':
        if (tokens.length == 2 && tokens[1].type == TokenTypes.identifier) {
          return KiwiWatermelonActionFactory.decr(tokens[1].text);
        }
        break;
      case 'INCRBY':
        if (tokens.length == 3 &&
            tokens[1].type == TokenTypes.identifier &&
            tokens[2].type == TokenTypes.number) {
          final value = int.tryParse(tokens[2].text);
          if (value != null) {
            return KiwiWatermelonActionFactory.incrBy(tokens[1].text, value);
          }
        }
        break;
      case 'DECRBY':
        if (tokens.length == 3 &&
            tokens[1].type == TokenTypes.identifier &&
            tokens[2].type == TokenTypes.number) {
          final value = int.tryParse(tokens[2].text);
          if (value != null) {
            return KiwiWatermelonActionFactory.decrBy(tokens[1].text, value);
          }
        }
        break;
      case 'INCRBYFLOAT':
        if (tokens.length == 3 &&
            tokens[1].type == TokenTypes.identifier &&
            (tokens[2].type == TokenTypes.float ||
                tokens[2].type == TokenTypes.number)) {
          final value = double.tryParse(tokens[2].text);
          if (value != null) {
            return KiwiWatermelonActionFactory.incrByFloat(
                tokens[1].text, value);
          }
        }
        break;
      case 'DECRBYFLOAT':
        if (tokens.length == 3 &&
            tokens[1].type == TokenTypes.identifier &&
            (tokens[2].type == TokenTypes.float ||
                tokens[2].type == TokenTypes.number)) {
          final value = double.tryParse(tokens[2].text);
          if (value != null) {
            return KiwiWatermelonActionFactory.decrByFloat(
                tokens[1].text, value);
          }
        }
        break;
    }

    return null;
  }
}
