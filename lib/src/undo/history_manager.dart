import '../action/base_action.dart';
import '../data_store.dart';
import '../action/action_event.dart';

class KiwiHistoryManager {
  final KiwiWatermelonDataStore store;
  List<KiwiActionEvent> undoStack = [];
  List<KiwiActionEvent> redoStack = [];

  KiwiHistoryManager({required this.store});

  void performAction(KiwiWatermelonAction action) {
    redoStack.clear();
    final result = action.execute(store);
    final event = result.event;
    if (event != null) {
      undoStack.add(event);
    }
  }

  void undo() {
    if (undoStack.isEmpty) return;
    KiwiActionEvent lastAction = undoStack.removeLast();
    lastAction.undo.applyPatch(store);
    redoStack.add(lastAction);
  }

  void redo() {
    if (redoStack.isEmpty) return;
    final event = redoStack.removeLast();
    event.redo.applyPatch(store);
    undoStack.add(event);
  }
}
