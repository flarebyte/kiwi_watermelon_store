import 'package:kiwi_watermelon_store/src/view_manager.dart';

import '../kiwi_watermelon_store.dart';
import 'action/base_action.dart';
import 'factory.dart';
import 'store/manager_options.dart';
import 'action/action_patch.dart';

abstract class KiwiWatermelonBaseSessionManager {
  void performActions(List<KiwiWatermelonAction> actions);
  void undo();
  void redo();

  void save(String key);
  void restore(String key);

  void registerViewManager(KiwiWatermelonViewManager manager);

  BaseStringDataStore mainStore();
}

class KiwiWatermelonSessionManager<A> extends KiwiWatermelonBaseSessionManager {
  final KiwiWatermelonOptions options;
  final KiwiWatermelonBaseFactory factory;
  late BaseStringDataStore store;
  final Map<String, Map<String, String>> snapshots = {};
  List<KiwiRedoUndo> undoStack = [];
  List<KiwiRedoUndo> redoStack = [];
  List<KiwiWatermelonViewManager> viewManagers = [];

  KiwiWatermelonSessionManager({required this.options, required this.factory}) {
    store = factory.createStringDataStore(options: options);
  }

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
    final redoPatches = KiwiPatches.splitPatch(options, redoPatch);
    final userRedoPatch = redoPatches.user;

    store.applyPatch(redoPatch);

    if (userRedoPatch != null) {
      final undoPatch = userRedoPatch.revertPatch(store);
      undoStack.add(KiwiRedoUndo(redo: redoPatch, undo: undoPatch));
    }
  }

  @override
  void undo() {
    if (undoStack.isEmpty) return;
    final lastUndo = undoStack.removeLast();
    store.applyPatch(lastUndo.undo);
    redoStack.add(lastUndo);
  }

  @override
  void redo() {
    if (redoStack.isEmpty) return;
    final event = redoStack.removeLast();
    store.applyPatch(event.redo);
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

  @override
  BaseStringDataStore mainStore() {
    return store;
  }

  @override
  void registerViewManager(KiwiWatermelonViewManager manager) {
    viewManagers.add(manager);
  }
}
