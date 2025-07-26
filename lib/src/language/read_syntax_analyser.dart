import '../action/read_action_factory.dart';
import '../select/select_base_action.dart';
import '../store/manager_options.dart';
import 'analysis_failure.dart';
import 'read_command_analyser.dart';
import 'semantic_exception.dart';
import 'token.dart';
import 'token_stream.dart';
import 'token_stream_flyweight.dart';

class KiwiWatermelonReadSyntaxAnalysis {
  final KiwiWatermelonAnalysisFailure? failure;
  final List<KiwiWatermelonSelectQuery<String>> actions;
  KiwiWatermelonReadSyntaxAnalysis({required this.actions, this.failure});

  bool isValid() {
    final invalid = failure != null;
    return !invalid;
  }
}

class KiwiWatermelonReadSyntaxAnalyser {
  final KiwiWatermelonOptions options;
  final String role;
  late KiwiReadCommandAnalyser commandAnalyser;
  static const String JOIN = 'JOIN';

  KiwiWatermelonReadSyntaxAnalyser(
      {required this.options, required this.role}) {
    commandAnalyser = KiwiReadCommandAnalyser(options: options, role: role);
  }

  KiwiWatermelonReadSyntaxAnalysis _success(
      List<KiwiWatermelonSelectQuery<String>> actions) {
    return KiwiWatermelonReadSyntaxAnalysis(actions: actions);
  }

  KiwiWatermelonReadSyntaxAnalysis _failure(
      KiwiWatermelonAnalysisFailure failure) {
    return KiwiWatermelonReadSyntaxAnalysis(actions: [], failure: failure);
  }

  KiwiWatermelonReadSyntaxAnalysis analyse(List<KiwiWatermelonToken> tokens) {
    final stream = KiwiWatermelonTokenStream(tokens);
    final tmpActions = <KiwiWatermelonSelectQuery<String>>[];

    try {
      while (!stream.isAtEnd) {
        final isNextJoin =
            KiwiTokenStreamFlyweight.isAnyKeyword(stream, [JOIN]);
        if (isNextJoin) {
          final joinAction = parseJoin(stream, tmpActions);
          tmpActions.clear();
          tmpActions.add(joinAction);
        } else {
          final action = commandAnalyser.parseSingleCommand(stream);
          tmpActions.add(action);
        }

        if (!stream.isAtEnd) {
          KiwiTokenStreamFlyweight.consumeSemicolon(stream);
        }
      }
      return _success(tmpActions);
    } catch (e) {
      if (e is KiwiWatermelonSemanticException) {
        return _failure(KiwiWatermelonAnalysisFailure(
          message: e.message,
          position: e.token.startPosition,
          index: e.token.startIndex,
          errorType: 'Syntax Analysis Error',
          contextCode: stream.current.text,
          expected: '',
          suggestion: 'Check syntax near this token.',
        ));
      }
      rethrow;
    }
  }

  KiwiWatermelonSelectQuery<String> parseJoin(KiwiWatermelonTokenStream stream,
      List<KiwiWatermelonSelectQuery<String>> childActions) {
    if (childActions.length < 2) {
      throw KiwiWatermelonSemanticException(
          'JOIN expect at least two actions but got ${childActions.length}',
          stream.current);
    }
    KiwiTokenStreamFlyweight.consumeIdentifier(stream);
    final separator = KiwiTokenStreamFlyweight.consumeIdentifier(stream);
    switch (separator.text) {
      case 'coma':
        {
          return KiwiWatermelonReadActionFactory.join(',', childActions);
        }
      case 'space':
        {
          return KiwiWatermelonReadActionFactory.join(' ', childActions);
        }
      default:
        throw KiwiWatermelonSemanticException(
            'JOIN should use a known separator', stream.current);
    }
  }
}
