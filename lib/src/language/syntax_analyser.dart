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

//   KiwiWatermelonSyntaxAnalysis analyse(List<KiwiWatermelonToken> tokens) {
//   final stream = KiwiWatermelonTokenStream(tokens);
//   final actions = <KiwiWatermelonAction>[];

//   try {
//     while (!stream.isAtEnd) {
//       final action = _parseSingleCommand(stream);
//       actions.add(action);
//       KiwiWatermelonTokenStreamFlyweight.consumeSemicolon(stream);
//     }
//     return _success(actions);
//   } catch (e) {
//     if (e is KiwiWatermelonSemanticException) {
//       return _failure(KiwiWatermelonAnalysisFailure(
//         message: e.message,
//         position: e.position,
//         index: e.index,
//         errorType: 'Syntax Analysis Error',
//         contextCode: stream.current.text,
//         expected: '',
//         suggestion: 'Check syntax near this token.',
//       ));
//     }
//     rethrow;
//   }
// }

// KiwiWatermelonAction _parseSingleCommand(KiwiWatermelonTokenStream stream) {
//   final token = stream.peek();
//   if (token == null || token.type != TokenTypes.identifier) {
//     throw KiwiWatermelonSemanticException(
//       'Expected command keyword (e.g., INCR)',
//       token?.startPosition,
//       token?.startIndex ?? -1,
//     );
//   }

//   final command = token.text.toUpperCase();
//   stream.consume(); // consume the command keyword

//   switch (command) {
//     case 'INCR':
//       final keyToken =
//           KiwiWatermelonTokenStreamFlyweight.consumeIdentifier(stream);
//       return KiwiWatermelonActionFactory.incr(keyToken.text);

//     case 'DECR':
//       final keyToken =
//           KiwiWatermelonTokenStreamFlyweight.consumeIdentifier(stream);
//       return KiwiWatermelonActionFactory.decr(keyToken.text);

//     case 'INCRBY':
//       final keyToken =
//           KiwiWatermelonTokenStreamFlyweight.consumeIdentifier(stream);
//       final valueToken = stream.consume();
//       final value = int.tryParse(valueToken?.text ?? '');
//       if (value == null) {
//         throw SemanticException(
//           'Expected integer after key for INCRBY',
//           valueToken?.startPosition,
//           valueToken?.startIndex ?? -1,
//         );
//       }
//       return KiwiWatermelonActionFactory.incrBy(keyToken.text, value);

//     case 'DECRBY':
//       final keyToken =
//           KiwiWatermelonTokenStreamFlyweight.consumeIdentifier(stream);
//       final valueToken = stream.consume();
//       final value = int.tryParse(valueToken?.text ?? '');
//       if (value == null) {
//         throw SemanticException(
//           'Expected integer after key for DECRBY',
//           valueToken?.startPosition,
//           valueToken?.startIndex ?? -1,
//         );
//       }
//       return KiwiWatermelonActionFactory.decrBy(keyToken.text, value);

//     case 'INCRBYFLOAT':
//       final keyToken =
//           KiwiWatermelonTokenStreamFlyweight.consumeIdentifier(stream);
//       final valueToken = stream.consume();
//       final value = double.tryParse(valueToken?.text ?? '');
//       if (value == null) {
//         throw SemanticException(
//           'Expected float after key for INCRBYFLOAT',
//           valueToken?.startPosition,
//           valueToken?.startIndex ?? -1,
//         );
//       }
//       return KiwiWatermelonActionFactory.incrByFloat(keyToken.text, value);

//     case 'DECRBYFLOAT':
//       final keyToken =
//           KiwiWatermelonTokenStreamFlyweight.consumeIdentifier(stream);
//       final valueToken = stream.consume();
//       final value = double.tryParse(valueToken?.text ?? '');
//       if (value == null) {
//         throw SemanticException(
//           'Expected float after key for DECRBYFLOAT',
//           valueToken?.startPosition,
//           valueToken?.startIndex ?? -1,
//         );
//       }
//       return KiwiWatermelonActionFactory.decrByFloat(keyToken.text, value);

//     default:
//       throw SemanticException(
//         'Unknown command "$command"',
//         token.startPosition,
//         token.startIndex,
//       );
//   }
// }
}
