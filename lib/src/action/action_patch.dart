import '../../kiwi_watermelon_store.dart';
import '../store/manager_options.dart';

class KiwiWatermelonPatch {
  final Map<String, String> updates;
  final List<String> deletions;

  KiwiWatermelonPatch({required this.updates, required this.deletions});

  applyPatch(BaseStringDataStore store) {
    //todo
  }
  revertPatch(BaseStringDataStore store) {
    //todo
  }

  static KiwiWatermelonPatch mergePatches(List<KiwiWatermelonPatch> patches){
    //todo
    return patches[0];
  }
  
}

class KiwiRedoUndo {
  final KiwiWatermelonPatch redo;
  final KiwiWatermelonPatch undo;

  KiwiRedoUndo({required this.redo, required this.undo});
}

class KiwiPatches {
  final KiwiWatermelonPatch? user;
  final KiwiWatermelonPatch? admin;

  KiwiPatches({required this.user, required this.admin});
  
  static KiwiPatches splitPatch(KiwiWatermelonOptions options, KiwiWatermelonPatch patch){
    //todo
    return KiwiPatches(admin: patch, user: patch);
  }
}

