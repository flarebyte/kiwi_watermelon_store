import 'package:kiwi_watermelon_store/src/action/action_factory.dart';
import 'package:kiwi_watermelon_store/src/store/data_store.dart';
import 'package:kiwi_watermelon_store/src/store/mem_data_store.dart';
import 'package:test/test.dart';

import '../code_fixtures.dart';

void main() {
  group('KiwiWatermelonActionFactory del operations', () {
    late BaseStringDataStore store;

    setUp(() {
      store = KiwiWatermelonDataStore(options: storeOptions);
    });

    test('flushDb should delete all keys', () {
      store.set('env:a', '1');
      store.set('env:b', '2');
      store.set('env:c', '3');

      final result = KiwiWatermelonActionFactory.flushDb().execute(store);

      expect(result.error, isNull);
      expect(result.patch?.deletions, containsAll(['env:a', 'env:b', 'env:c']));
      expect(result.patch?.updates, isEmpty);
    });
//
    test('delKeys should delete keys matching single wildcard pattern', () {
      store.set('env:color:red:site:1', 'value1');
      store.set('env:color:blue:site:2', 'value2');
      store.set('env:shape:square:site:1', 'value3');

      final result = KiwiWatermelonActionFactory.delKeys(
        ['env:color:*:site:*'],
      ).execute(store);

      expect(result.error, isNull);
      expect(
          result.patch?.deletions,
          containsAll([
            'env:color:red:site:1',
            'env:color:blue:site:2',
          ]));

      expect(
          result.patch?.deletions, isNot(contains('env:shape:square:site:1')));
    });

    test('delKeys should delete keys matching multiple patterns', () {
      store.set('env:color:red:site:1', 'value1');
      store.set('env:shape:square:site:2', 'value2');
      store.set('env:shape:circle:site:3', 'value3');

      final result = KiwiWatermelonActionFactory.delKeys(
        ['env:color:*:site:*', 'env:shape:circle:*'],
      ).execute(store);

      expect(result.error, isNull);
      expect(
          result.patch?.deletions,
          containsAll([
            'env:color:red:site:1',
            'env:shape:circle:site:3',
          ]));

      expect(
          result.patch?.deletions, isNot(contains('env:shape:square:site:2')));
    });

    test('delKeys with no matching patterns should do nothing', () {
      store.set('env:data:one', '1');
      store.set('env:data:two', '2');

      final result = KiwiWatermelonActionFactory.delKeys(
        ['env:other:*'],
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.deletions, isEmpty);
      expect(result.patch?.updates, isEmpty);
    });
  });
}
