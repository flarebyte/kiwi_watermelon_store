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

  KiwiWatermelonReadSyntaxAnalyser({required this.options, required this.role}) {
    commandAnalyser = KiwiReadCommandAnalyser(options: options, role: role);
  }

  KiwiWatermelonReadSyntaxAnalysis _success(List<KiwiWatermelonSelectQuery<String>> actions) {
    return KiwiWatermelonReadSyntaxAnalysis(actions: actions);
  }

  KiwiWatermelonReadSyntaxAnalysis _failure(KiwiWatermelonAnalysisFailure failure) {
    return KiwiWatermelonReadSyntaxAnalysis(actions: [], failure: failure);
  }

  KiwiWatermelonReadSyntaxAnalysis analyse(List<KiwiWatermelonToken> tokens) {
    final stream = KiwiWatermelonTokenStream(tokens);
    final actions = <KiwiWatermelonSelectQuery<String>>[];

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
