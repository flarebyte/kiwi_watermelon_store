import '../kiwi_watermelon_store.dart';
import 'action/base_action.dart';
import 'event_bus.dart';
import 'factory.dart';
import 'listener/handler.dart';
import 'patch_executor.dart';
import 'store/manager_options.dart';
import 'action/action_patch.dart';

abstract class KiwiWatermelonBaseSessionManager {
  void performActions(List<KiwiWatermelonAction> actions);
  void undo();
  void redo();

  void save(String key);
  void restore(String key);
  void dispose();

  BaseStringDataStore mainStore();

  PatchEventBus? get eventBus;
}

class KiwiWatermelonSessionManager extends KiwiWatermelonBaseSessionManager {
  final KiwiWatermelonOptions options;
  final KiwiWatermelonBaseFactory factory;
  late BaseStringDataStore store;
  final Map<String, Map<String, String>> snapshots = {};
  late KiwiPatchExecutor patchExecutor;
  KiwiWatermelonOnViewUpdate? onUpdate;
  List<KiwiRedoUndo> undoStack = [];
  List<KiwiRedoUndo> redoStack = [];
  bool useEventBus;
  late PatchEventBus? _eventBus;

  KiwiWatermelonSessionManager(
      {required this.options,
      required this.factory,
      this.onUpdate,
      this.useEventBus = false})
      : _eventBus = useEventBus ? PatchEventBus() : null {
    store = factory.createStringDataStore(options: options);
    patchExecutor = KiwiPatchExecutor(options: options);
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

    executePatch(redoPatch);

    if (userRedoPatch != null) {
      final undoPatch = userRedoPatch.revertPatch(store);
      undoStack.add(KiwiRedoUndo(redo: redoPatch, undo: undoPatch));
    }
  }

  @override
  void undo() {
    if (undoStack.isEmpty) return;
    final lastUndo = undoStack.removeLast();
    executePatch(lastUndo.undo);
    redoStack.add(lastUndo);
  }

  @override
  void redo() {
    if (redoStack.isEmpty) return;
    final event = redoStack.removeLast();
    executePatch(event.redo);
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
      _eventBus?.publish(KiwiWatermelonEvent(
          eventType: KiwiWatermelonEventType.restore, readStore: store));
    }
  }

  @override
  BaseStringDataStore mainStore() {
    return store;
  }

  void executePatch(KiwiWatermelonPatch patch) {
    patchExecutor.executePatch(store, patch);
    onUpdate!(patch);
    _eventBus?.publish(KiwiWatermelonEvent(
        patch: patch,
        eventType: KiwiWatermelonEventType.update,
        readStore: store));
  }

  @override
  PatchEventBus? get eventBus => _eventBus;

  @override
  void dispose() {
    _eventBus?.dispose();
  }
}
