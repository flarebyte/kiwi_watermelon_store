import '../data_store.dart';

class KiwiActionPatch {
  final Map<String, String> updates;
  final List<String> deletions;

  KiwiActionPatch({required this.updates, required this.deletions});

  applyPatch(KiwiWatermelonDataStore store) {
    //todo
  }
  revertPatch(KiwiWatermelonDataStore store) {
    //todo
  }

  static KiwiActionPatch mergePatches(List<KiwiActionPatch> patches){
    //todo
    return patches[0];
  }
}

class KiwiRedoUndo {
  final KiwiActionPatch redo;
  final KiwiActionPatch undo;

  KiwiRedoUndo({required this.redo, required this.undo});
}

