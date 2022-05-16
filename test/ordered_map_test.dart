import 'dart:math';

import 'package:awesome_poll_app/utils/ordered_map.dart';
import 'package:flutter_test/flutter_test.dart';

OrderedMapListEntry<T> _entry<T>(String k, T t, String? n) => OrderedMapListEntry(key: k, value: t, nextElement: n);

main() {
  var typeFactory = <T>({required String key, required T value}) => value;
  test('null gives empty list', () {
    var list = OrderedMapList.from(null, typeFactory);
    expect(list.size, 0);
    expect(list.listEntries(), []);
    expect(list.listElements().toList(), []);
    expect(list.toJson(), {});
  });
  test('empty list is empty', () {
    var list = OrderedMapList.empty();
    expect(list.size, 0);
    expect(list.listEntries(), []);
    expect(list.listElements().toList(), []);
    expect(list.toJson(), {});
  });
  test('insert first on empty', () {
    var list = OrderedMapList<String>.empty();
    list.insert(key: 'test_k', el: 'test');
    expect(list.size, 1);
    expect(list.listElements().toList(), ['test']);
    expect(list.toJson(), {
      '_first': 'test_k',
      'test_k': {
        'next': null,
        'value': 'test',
      },
    });
  });
  test('insert last', () {
    var list = OrderedMapList<String>.empty();
    list
      ..insert(key: 'test1_k', el: 'test1')
      ..insert(key: 'test2_k', el: 'test2');
    expect(list.size, 2);
    expect(list.listElements().toList(), ['test1', 'test2']);
    expect(list.toJson(), {
      '_first': 'test1_k',
      'test1_k': {
        'next': 'test2_k',
        'value': 'test1',
      },
      'test2_k': {
        'next': null,
        'value': 'test2',
      },
    });
  });
  test('insert on idx', () {
    var list = OrderedMapList<String>.empty();
    list
      ..insert(key: 'test1_k', el: 'test1')
      ..insert(key: 'test2_k', el: 'test2')
      ..insert(key: 'test3_k', el: 'test3', idx: 1);
    expect(list.toJson(), {
      '_first': 'test1_k',
      'test1_k': {
        'next': 'test3_k',
        'value': 'test1',
      },
      'test2_k': {
        'next': null,
        'value': 'test2',
      },
      'test3_k': {
        'next': 'test2_k',
        'value': 'test3',
      },
    });
    list.insert(key: 'test4_k', el: 'test4', idx: 0);
    expect(list.toJson(), {
      '_first': 'test4_k',
      'test1_k': {
        'next': 'test3_k',
        'value': 'test1',
      },
      'test2_k': {
        'next': null,
        'value': 'test2',
      },
      'test3_k': {
        'next': 'test2_k',
        'value': 'test3',
      },
      'test4_k': {
        'next': 'test1_k',
        'value': 'test4',
      },
    });
  });
  test('primitive serialize', () {
    var empty = OrderedMapList<String>.from({}, typeFactory);
    expect(empty.size, 0);
    expect(empty.toJson(), {});
    var simple = {
      '_first': 'test1_k',
      'test1_k': {
        'next': 'test3_k',
        'value': 'test1',
      },
      'test2_k': {
        'next': null,
        'value': 'test2',
      },
      'test3_k': {
        'next': 'test2_k',
        'value': 'test3',
      },
    };
    var simpleList = OrderedMapList.from(simple, typeFactory);
    expect(simpleList.size, simple.length - 1);
    expect(simpleList.toJson(), simple);
  });
  test('non empty', () => expect(() => OrderedMapList.from({'non_empty': ''}, typeFactory), throwsAssertionError));
  test(
      'valid but broken chain',
      () => expect(
          () => OrderedMapList.from({
                '_first': 'test1_k',
                'test1_k': {
                  'next': 'test2_k',
                  'value': 'test1',
                },
                'test2_k': {
                  'next': null,
                  'value': 'test2',
                },
                'test3_k': {
                  'next': 'test2_k',
                  'value': 'test3',
                },
              }, typeFactory),
          throwsAssertionError));
  test('find', () {
    var list = OrderedMapList<String>.empty();
    list.insert(key: 'test1_k', el: 'test1');
    expect(list.find('test1_k') != null, true);
    expect(list.find('test1_k'), 'test1');
    list.insert(key: 'test2_k', el: 'test2');
    expect(list.find('test2_k'), 'test2');
    expect(list.find('not_present') == null, true);
  });
  test('duplicated key should replace existing', () {
    var list = OrderedMapList<String>.empty();
    list
      ..insert(key: 'test1_k', el: 'test1')
      ..insert(key: 'test2_k', el: 'test2')
      ..insert(key: 'test3_k', el: 'test3');
    list.insert(key: 'test2_k', el: 'test2_replaced');
    expect(list.find('test2_k'), 'test2_replaced');
    expect(list.toJson(), {
      '_first': 'test1_k',
      'test1_k': {
        'next': 'test2_k',
        'value': 'test1',
      },
      'test2_k': {
        'next': 'test3_k',
        'value': 'test2_replaced',
      },
      'test3_k': {
        'next': null,
        'value': 'test3',
      },
    });
  });
  test('delete invalid', () {
    var list = OrderedMapList<String>.empty();
    expect(list.deleteByKey('invalid'), false);
    expect(() => list.deleteByIndex(0), throwsAssertionError);
  });
  test('delete with key', () {
    var list = OrderedMapList<String>.empty();
    //first
    list.insert(key: 'test1_k', el: 'test1');
    expect(list.deleteByKey('test1_k'), true);
    expect(list.size, 0);
    expect(list.toJson(), {});
    //middle
    list
      ..insert(key: 'test1_k', el: 'test1')
      ..insert(key: 'test2_k', el: 'test2')
      ..insert(key: 'test3_k', el: 'test3');
    expect(list.deleteByKey('test2_k'), true);
    expect(list.size, 2);
    //end
    expect(list.deleteByKey('test3_k'), true);
    expect(list.size, 1);
    expect(list.listElements().toList(), ['test1']);
  });
  test('delete with index', () {
    var list = OrderedMapList<String>.empty()
      ..insert(key: 'test1_k', el: 'test1')
      ..insert(key: 'test2_k', el: 'test2')
      ..insert(key: 'test3_k', el: 'test3');
    expect(() => list.deleteByIndex(1), returnsNormally);
    expect(list.listElements().toList(), ['test1', 'test3']);
    expect(() => list.deleteByIndex(1), returnsNormally);
    expect(list.listElements().toList(), ['test1']);
    expect(() => list.deleteByIndex(0), returnsNormally);
    expect(list.listElements().toList(), []);
  });
  test('retype T', () {
    var list = OrderedMapList<String>.empty()
      ..insert(key: 'test1_k', el: '1')
      ..insert(key: 'test2_k', el: '2')
      ..insert(key: 'test3_k', el: '3');
    var intList = list.retype((e) => int.parse(e));
    expect(intList.listElements().toList(), [1, 2, 3]);
    //with serialization
    var intMap = intList.toJson();
    var newIntList = OrderedMapList.from(intMap, typeFactory<int>); //constructor tear-off
    expect(newIntList.listElements().toList(), [1, 2, 3]);
    var stringList = newIntList.retype((e) => '$e');
    expect(stringList.listElements().toList(), ['1', '2', '3']);
  });
}
