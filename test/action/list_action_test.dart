import 'package:kiwi_watermelon_store/src/action/action_factory.dart';
import 'package:kiwi_watermelon_store/src/store/data_store.dart';
import 'package:kiwi_watermelon_store/src/store/mem_data_store.dart';
import 'package:test/test.dart';

import '../code_fixtures.dart';

void main() {
  group('KiwiWatermelonActionFactory list operations', () {
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
      store.set('env:colors', 'red,blue,red,yellow,red');
      final result = KiwiWatermelonActionFactory.lrem('env:colors', 0, 'red',
              separator: ',')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:colors'], equals('blue,yellow'));
    });

    test('lrem with count > 0 should remove first occurrences', () {
      store.set('env:colors', 'red,blue,red,yellow,red');
      final result = KiwiWatermelonActionFactory.lrem('env:colors', 2, 'red',
              separator: ',')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:colors'], equals('blue,yellow,red'));
    });

    test('lrem with count < 0 should remove from end', () {
      store.set('env:colors', 'red,blue,red,yellow,red');
      final result = KiwiWatermelonActionFactory.lrem('env:colors', -1, 'red',
              separator: ',')
          .execute(store);

      expect(result.error, isNull);
      expect(
          result.patch?.updates['env:colors'], equals('red,blue,red,yellow'));
    });

    test('ltrim should slice the list correctly', () {
      store.set('env:nums', '1,2,3,4,5');
      final result =
          KiwiWatermelonActionFactory.ltrim('env:nums', 1, 3, separator: ',')
              .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:nums'], equals('2,3,4'));
    });

    test('rpoplpush should move last of source to front of destination', () {
      store.set('env:source', 'a,b,c');
      store.set('env:dest', 'x,y');
      final result = KiwiWatermelonActionFactory.rpoplpush(
              'env:source', 'env:dest',
              separator: ',')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:source'], equals('a,b'));
      expect(result.patch?.updates['env:dest'], equals('c,x,y'));
    });

    test('lmove LEFT to RIGHT', () {
      store.set('env:src', 'a,b,c');
      store.set('env:dst', '1,2');
      final result = KiwiWatermelonActionFactory.lmove(
              'env:src', 'env:dst', 'LEFT', 'RIGHT',
              separator: ',')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:src'], equals('b,c'));
      expect(result.patch?.updates['env:dst'], equals('1,2,a'));
    });

    test('lmove RIGHT to LEFT', () {
      store.set('env:src', 'a,b,c');
      store.set('env:dst', '1,2');
      final result = KiwiWatermelonActionFactory.lmove(
              'env:src', 'env:dst', 'RIGHT', 'LEFT',
              separator: ',')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:src'], equals('a,b'));
      expect(result.patch?.updates['env:dst'], equals('c,1,2'));
    });

    test('lpush on non-existent key creates new list', () {
      final result = KiwiWatermelonActionFactory.lpush(
              'env:newlist', ['foo', 'bar'],
              separator: ',')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:newlist'], equals('bar,foo'));
    });
    test('ltrims with out-of-range indices should clamp gracefully', () {
      store.set('env:numbers', '10,20,30,40');
      final result = KiwiWatermelonActionFactory.ltrim(
        'env:numbers',
        -5,
        10,
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:numbers'], equals('10,20,30,40'));
    });
    test('ltrims on empty list should result in empty list', () {
      store.set('env:emptylist', '');
      final result = KiwiWatermelonActionFactory.ltrim(
        'env:emptylist',
        0,
        1,
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:emptylist'], equals(''));
    });
    test('rpoplpush from empty source should do nothing', () {
      store.set('env:source', '');
      store.set('env:dest', 'x,y');

      final result = KiwiWatermelonActionFactory.rpoplpush(
        'env:source',
        'env:dest',
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates.isEmpty, isTrue);
    });

    test('lmove with source == destination should move correctly', () {
      store.set('env:selfmove', 'a,b,c');

      final result = KiwiWatermelonActionFactory.lmove(
        'env:selfmove',
        'env:selfmove',
        'RIGHT',
        'LEFT',
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:selfmove'], equals('c,a,b'));
    });
    test('lrem removes all when single element matches', () {
      store.set('env:single', 'x');
      final result = KiwiWatermelonActionFactory.lrem(
        'env:single',
        0,
        'x',
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:single'], equals(''));
    });
    test('rpush on non-existent key creates new list', () {
      final result = KiwiWatermelonActionFactory.rpush(
        'env:newlist2',
        ['x', 'y'],
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:newlist2'], equals('x,y'));
    });
    test('lrem on non-existent key is a no-op', () {
      final result = KiwiWatermelonActionFactory.lrem(
        'env:missing',
        0,
        'nope',
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:missing'], equals(''));
    });
  });
}
