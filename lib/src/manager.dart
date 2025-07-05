import 'package:kiwi_watermelon_store/src/listener/handler.dart';

import '../kiwi_watermelon_store.dart';
import 'action/base_action.dart';
import 'store/mem_data_store.dart';
import 'action/action_patch.dart';

abstract class KiwiWatermelonBaseSessionManager {
  void performActions(List<KiwiWatermelonAction> actions);
  void undo();
  void redo();

  void save(String key);
  void restore(String key);

  BaseStringDataStore mainStore();
  
  void registerPrimaryView<T>(KiwiWatermelonViewReducer<T> reducer, KiwiWatermelonOnViewUpdate onUpdate);
  BaseTypedDataStore<T> primaryView<T>();
  
}

class KiwiWatermelonSessionManager extends KiwiWatermelonBaseSessionManager {
  KiwiWatermelonDataStore store;
  final Map<String, Map<String, String>> snapshots = {};
  List<KiwiRedoUndo> undoStack = [];
  List<KiwiRedoUndo> redoStack = [];

  KiwiWatermelonSessionManager({required this.store});
  
  @override
  void performActions(List<KiwiWatermelonAction> actions) {
    redoStack.clear();
    final List<KiwiWatermelonPatch> patches = [];
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

    final redoPatch = KiwiWatermelonPatch.mergePatches(patches);
    final redoPatches = KiwiPatches.splitPatch(store.options, redoPatch);
    final userRedoPatch = redoPatches.user;

    redoPatch.applyPatch(store);

    if (userRedoPatch != null) {
      final undoPatch = userRedoPatch.revertPatch(store);
      undoStack.add(KiwiRedoUndo(redo: redoPatch, undo: undoPatch));
    }
  }

  @override
  void undo() {
    if (undoStack.isEmpty) return;
    final lastUndo = undoStack.removeLast();
    lastUndo.undo.applyPatch(store);
    redoStack.add(lastUndo);
  }

  @override
  void redo() {
    if (redoStack.isEmpty) return;
    final event = redoStack.removeLast();
    event.redo.applyPatch(store);
    undoStack.add(event);
  }
  
  @override
  void save(String key) {
    snapshots.putIfAbsent(key, () => store.toUnmodifiableMap());
  }

  @override
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
  
  @override
  BaseTypedDataStore<T> primaryView<T>() {
    // TODO: implement primaryView
    throw UnimplementedError();
  }
  
  @override
  void registerPrimaryView<T>(KiwiWatermelonViewReducer<T> reducer, KiwiWatermelonOnViewUpdate onUpdate) {
    // TODO: implement registerPrimaryView
  }
  
  @override
  BaseStringDataStore mainStore() {
   return store;
  }
}
