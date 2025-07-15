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

    test('lpush should prepend values', () {
      store.set('env:mylist', 'c,d');
      final result = KiwiWatermelonActionFactory.lpush('env:mylist', ['a', 'b'],
              separator: ',')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:mylist'], equals('b,a,c,d'));
    });

    test('rpush should append values', () {
      store.set('env:mylist', 'x,y');
      final result =
          KiwiWatermelonActionFactory.rpush('env:mylist', ['z'], separator: ',')
              .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:mylist'], equals('x,y,z'));
    });

    test('lrem with count = 0 should remove all occurrences', () {
      store.set('colors', 'red,blue,red,yellow,red');
      final result =
          KiwiWatermelonActionFactory.lrem('colors', 0, 'red', separator: ',')
              .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['colors'], equals('blue,yellow'));
    });

    test('lrem with count > 0 should remove first occurrences', () {
      store.set('colors', 'red,blue,red,yellow,red');
      final result =
          KiwiWatermelonActionFactory.lrem('colors', 2, 'red', separator: ',')
              .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['colors'], equals('blue,yellow,red'));
    });

    test('lrem with count < 0 should remove from end', () {
      store.set('colors', 'red,blue,red,yellow,red');
      final result =
          KiwiWatermelonActionFactory.lrem('colors', -1, 'red', separator: ',')
              .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['colors'], equals('red,blue,red,yellow'));
    });

    test('ltrim should slice the list correctly', () {
      store.set('nums', '1,2,3,4,5');
      final result =
          KiwiWatermelonActionFactory.ltrim('nums', 1, 3, separator: ',')
              .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['nums'], equals('2,3,4'));
    });

    test('rpoplpush should move last of source to front of destination', () {
      store.set('source', 'a,b,c');
      store.set('dest', 'x,y');
      final result = KiwiWatermelonActionFactory.rpoplpush('source', 'dest',
              separator: ',')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['source'], equals('a,b'));
      expect(result.patch?.updates['dest'], equals('c,x,y'));
    });

    test('rpoplpush should error on empty source', () {
      store.set('source', '');
      store.set('dest', 'x');
      final result = KiwiWatermelonActionFactory.rpoplpush('source', 'dest',
              separator: ',')
          .execute(store);

      expect(result.patch, isNull);
      expect(result.error?.message, contains('empty'));
    });

    test('lmove LEFT to RIGHT', () {
      store.set('src', 'a,b,c');
      store.set('dst', '1,2');
      final result = KiwiWatermelonActionFactory.lmove(
              'src', 'dst', 'LEFT', 'RIGHT',
              separator: ',')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['src'], equals('b,c'));
      expect(result.patch?.updates['dst'], equals('1,2,a'));
    });

    test('lmove RIGHT to LEFT', () {
      store.set('src', 'a,b,c');
      store.set('dst', '1,2');
      final result = KiwiWatermelonActionFactory.lmove(
              'src', 'dst', 'RIGHT', 'LEFT',
              separator: ',')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['src'], equals('a,b'));
      expect(result.patch?.updates['dst'], equals('c,1,2'));
    });

    test('lpush on non-existent key creates new list', () {
      final result = KiwiWatermelonActionFactory.lpush(
              'newlist', ['foo', 'bar'],
              separator: ',')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['newlist'], equals('foo,bar'));
    });
  });
}
