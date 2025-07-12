import 'package:kiwi_watermelon_store/src/language/token.dart';

import '../action/base_action.dart';
import '../store/manager_options.dart';
import 'analysis_failure.dart';

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
    //TODO
    return _success([]);
  }
}
