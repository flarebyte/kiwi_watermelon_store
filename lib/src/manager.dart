import 'action/base_action.dart';
import 'data_store.dart';
import 'action/action_patch.dart';

class KiwiWatermelonManager {
  KiwiWatermelonDataStore store;
  final Map<String, Map<String, String>> snapshots = {};
  List<KiwiRedoUndo> undoStack = [];
  List<KiwiRedoUndo> redoStack = [];

  KiwiWatermelonManager({required this.store});

  void performActions(List<KiwiWatermelonAction> actions) {
    redoStack.clear();
    final List<KiwiActionPatch> patches = [];
    for (var action in actions) {
      final result = action.execute(store);
      final patch = result.patch;
      if (patch != null) {
        patches.add(patch);
      }
    }

    if (patches.isEmpty) {
      return;
    }

    final redoPatch = KiwiActionPatch.mergePatches(patches);
    final undoPatch = redoPatch.revertPatch(store);
    redoPatch.applyPatch(store);

    undoStack.add(KiwiRedoUndo(redo: redoPatch, undo: undoPatch));
  }

  void undo() {
    if (undoStack.isEmpty) return;
    final lastUndo = undoStack.removeLast();
    lastUndo.undo.applyPatch(store);
    redoStack.add(lastUndo);
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
      store.clear();
      store.addAll(restorable);
    }
  }

  KiwiWatermelonDataStore getStore() {
    return store;
  }
}
