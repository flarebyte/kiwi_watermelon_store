import 'select/select_base_action.dart';
import 'store/manager_options.dart';
import 'store_holder.dart';

abstract class KiwiWatermelonBaseSessionReader {
  String? performStringQuery(KiwiWatermelonSelectQuery<String> queryObj);

  KiwiWatermelonStoreHolder storeHolder();
}

class KiwiWatermelonSessionReader extends KiwiWatermelonBaseSessionReader {
  final KiwiWatermelonOptions options;
  late KiwiWatermelonStoreHolder mainStoreHolder;

  KiwiWatermelonSessionReader(
      {required this.options, required this.mainStoreHolder});

  @override
  String? performStringQuery(KiwiWatermelonSelectQuery<String> queryObj) {
    return null;
  }

  @override
  KiwiWatermelonStoreHolder storeHolder() {
    return mainStoreHolder;
  }
}
