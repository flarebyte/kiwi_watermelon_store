import 'package:kiwi_watermelon_store/src/action/action_factory.dart';
import 'package:kiwi_watermelon_store/src/store/data_store.dart';
import 'package:kiwi_watermelon_store/src/store/mem_data_store.dart';
import 'package:test/test.dart';

import '../code_fixtures.dart';

void main() {
  group('KiwiWatermelonActionFactory integer operations', () {
    late BaseStringDataStore store;

    setUp(() {
      store = KiwiWatermelonDataStore(options: storeOptions);
    });

    test('incr on nonexistent key sets to 1', () {
      final result =
          KiwiWatermelonActionFactory.incr('env:counter').execute(store);
      expect(result.error, isNull);
      expect(result.patch?.updates['env:counter'], '1');
    });

 });
}
