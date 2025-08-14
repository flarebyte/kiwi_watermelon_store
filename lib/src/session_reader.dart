import 'select/select_base_action.dart';
import 'store/manager_options.dart';
import 'store_holder.dart';

abstract class KiwiWatermelonBaseSessionReader {
  String? performStringQuery(KiwiWatermelonSelectQuery<String> queryObj);

  KiwiWatermelonReadStoreHolder storeHolder();
}

class KiwiWatermelonSessionReader extends KiwiWatermelonBaseSessionReader {
  final KiwiWatermelonOptions options;
  late KiwiWatermelonReadStoreHolder readStoreHolder;

  KiwiWatermelonSessionReader(
      {required this.options, required this.readStoreHolder});

  @override
  String? performStringQuery(KiwiWatermelonSelectQuery<String> queryObj) {
    return null;
  }

  @override
  KiwiWatermelonReadStoreHolder storeHolder() {
    return readStoreHolder;
  }
}
