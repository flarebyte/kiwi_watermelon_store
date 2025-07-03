import '../action/action_patch.dart';

class KiwiWatermelonUpdateEvent {

final int id;
final String actor;
final KiwiActionPatch patch;

  KiwiWatermelonUpdateEvent({required this.id, required this.actor, required this.patch});


}