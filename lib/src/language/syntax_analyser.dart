import '../action/base_action.dart';
import '../store/manager_options.dart';
import 'analysis_failure.dart';
import 'command_analyser.dart';
import 'semantic_exception.dart';
import 'token.dart';
import 'token_stream.dart';
import 'token_stream_flyweight.dart';

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
  late KiwiCommandAnalyser commandAnalyser;

  KiwiWatermelonSyntaxAnalyzer({required this.options}) {
    commandAnalyser = KiwiCommandAnalyser(options: options);
  }

  KiwiWatermelonSyntaxAnalysis _success(List<KiwiWatermelonAction> actions) {
    return KiwiWatermelonSyntaxAnalysis(actions: actions);
  }

  KiwiWatermelonSyntaxAnalysis _failure(KiwiWatermelonAnalysisFailure failure) {
    return KiwiWatermelonSyntaxAnalysis(actions: [], failure: failure);
  }

  KiwiWatermelonSyntaxAnalysis analyse(List<KiwiWatermelonToken> tokens) {
    final stream = KiwiWatermelonTokenStream(tokens);
    final actions = <KiwiWatermelonAction>[];

    try {
      while (!stream.isAtEnd) {
        final action = commandAnalyser.parseSingleCommand(stream);
        actions.add(action);
        if (!stream.isAtEnd) {
          KiwiTokenStreamFlyweight.consumeSemicolon(stream);
        }
      }
      return _success(actions);
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
}
