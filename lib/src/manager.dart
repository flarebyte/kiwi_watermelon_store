import 'action/base_action.dart';
import 'store/mem_data_store.dart';
import 'action/action_patch.dart';
import 'listener/update_event.dart';

abstract class KiwiWatermelonBaseSessionManager {
  void performActions(List<KiwiWatermelonAction> actions);
  void undo();
  void redo();
  void save(String key);
  void restore(String key);
}

class KiwiWatermelonSessionManager extends KiwiWatermelonBaseSessionManager {
  KiwiWatermelonDataStore store;
  final Map<String, Map<String, String>> snapshots = {};
  List<KiwiRedoUndo> undoStack = [];
  List<KiwiRedoUndo> redoStack = [];

  KiwiWatermelonSessionManager({required this.store});

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
    final redoPatches = KiwiPatches.splitPatch(store.options, redoPatch);
    final userRedoPatch = redoPatches.user;

    redoPatch.applyPatch(store);

    if (userRedoPatch != null) {
      final undoPatch = userRedoPatch.revertPatch(store);
      undoStack.add(KiwiRedoUndo(redo: redoPatch, undo: undoPatch));
    }
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

  publishEvent(KiwiActionPatch patch, String actor) {
    //todo
    KiwiWatermelonUpdateEvent event =
        KiwiWatermelonUpdateEvent(patch: patch, id: 0, actor: actor);
  }
}
