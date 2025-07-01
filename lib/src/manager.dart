import 'action/base_action.dart';
import 'data_store.dart';
import 'action/action_event.dart';

class KiwiWatermelonManager {
  KiwiWatermelonDataStore store;
  final Map<String, Map<String, String>> snapshots = {};
  List<KiwiActionEvent> undoStack = [];
  List<KiwiActionEvent> redoStack = [];

  KiwiWatermelonManager({required this.store});

  void performActions(List<KiwiWatermelonAction> actions) {
    redoStack.clear();
    final events = [];
    for (var action in actions) {
       final result = action.execute(store);
       final event = result.event;
       if (event != null) {
        events.add(event);
       }
    }
   
    if (events.isNotEmpty) {
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

  void save(String key) {
    snapshots.putIfAbsent(key, () => store.toUnmodifiableMap());
  }

  void restore(String key) {
    final restorable = snapshots[key];
    if (restorable != null) {
      store = KiwiWatermelonDataStore.fromMap(restorable);
    }
  }

  KiwiWatermelonDataStore getStore() {
    return store;
  }
}
