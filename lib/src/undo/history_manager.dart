import '../action/base_action.dart';
import '../data_store.dart';
import 'action_event.dart';

class KiwiHistoryManager {
  final KiwiWatermelonDataStore store;
  List<KiwiActionEvent> undoStack = [];
  List<KiwiActionEvent> redoStack = [];

  KiwiHistoryManager({required this.store});

void performAction(KiwiWatermelonAction action) {
  undoStack.add(action);
  redoStack.clear();
  action.execute(store);
}

void undo() {
  if (undoStack.isEmpty) return;
  KiwiActionEvent lastAction = undoStack.removeLast();
  lastAction.undo.applyPatch(store);
  redoStack.add(lastAction);
}

void redo() {
  if (redoStack.isEmpty) return;
  Action action = redoStack.removeLast();
  action.execute();
  undoStack.add(action);
}

}