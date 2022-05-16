import 'package:awesome_poll_app/db.dart';
import 'package:equatable/equatable.dart';
import 'package:reactive_forms/reactive_forms.dart';

//behaves like a list, but is actually a map
//it will wrap T as 'value' field with a 'next' attribute which will indicate
// what item will come next
//combined with all the entries it will create a special '_first' field, which
// indicates what the first element will be
//since dart doesn't support dynamic type factories, from() will expect a
// callback which will construct each object of type T

//note: from() will fail, if there are elements which are not part of the
// linking chain, starting from '_first'
class OrderedMapList<T> {
  String? _first;
  late List<OrderedMapListEntry<T>> _listElements = [];

  //O(n^2), probably not an issue
  OrderedMapListEntry<T> _insert({required String key, int? idx, required T el}) {
    var existing = _find(key);
    if(existing != null) {
      existing.value = el;
      return existing;
    }
    return _insertUnsafe(OrderedMapListEntry(value: el, key: key), idx);
  }

  OrderedMapListEntry<T> _insertUnsafe(OrderedMapListEntry<T> entry, int? idx) {
    idx ??= _listElements.length;
    assert(idx >= 0 && idx <= _listElements.length, 'idx is out of range');
    if (idx == 0) {
      if(_first == null) {
        _first = entry.key;
        _listElements.insert(0, entry);
        return entry;
      } else {
        var nextElement = _first;
        entry.nextElement = nextElement;
        _first = entry.key;
        _listElements.insert(0, entry);
        return entry;
      }
    } else {
      var insertPosition = _listElements[idx - 1];
      var nextElement = insertPosition.nextElement;
      insertPosition.nextElement = entry.key;
      entry.nextElement = nextElement;
      _listElements.insert(idx, entry);
      return entry;
    }
  }

  void insert({required String key, int? idx, required T el}) {
    _insert(key: key, idx: idx, el: el);
  }

  void swap(int a, int b) {
    assert(a >= 0 && a < _listElements.length, 'first swap element is out of bound');
    assert(b >= 0 && b < _listElements.length, 'second swap element is out of bound');
    var _a = _listElements[a];
    var _b = _listElements[b];
    deleteByIndex(a);
    _insertUnsafe(_b, a);
    deleteByIndex(b);
    _insertUnsafe(_a, b);
  }

  void deleteByIndex(int idx) {
    assert(idx >= 0 && idx < _listElements.length, 'idx is out of range');
    if (idx == 0) {
      var nextKey = _listElements.length > 1 ? _listElements[1].nextElement : null;
      _first = nextKey;
      _listElements.removeAt(0);
    } else {
      var current = _listElements[idx - 1];
      var newCurrent = _listElements[idx - 1];
      newCurrent.nextElement = current.nextElement;
      _listElements.removeAt(idx);
    }
  }

  bool deleteByKey(String key) {
    for(int i = 0; i < _listElements.length; i++) {
      if(key == _listElements[i].key) {
        deleteByIndex(i);
        return true;
      }
    }
    return false;
  }

  int? _findIndex(String key) {
    for(int i = 0; i < _listElements.length; i++) {
      if(_listElements[i].key == key) {
        return i;
      }
    }
    return null;
  }

  int? findIndex(String key) => _findIndex(key);

  OrderedMapListEntry<T>? _find(String key) {
    var idx = _findIndex(key);
    return idx == null ? null : _listElements[idx];
  }

  T? find(String key) => _find(key)?.value;

  int get size => _listElements.length;

  Iterable<T> listElements() => _listElements.map((e) => e.value);

  List<OrderedMapListEntry<T>> listEntries() => _listElements.toList();

  OrderedMapList<E> retype<E>(E Function(T e) toElement) {
    var ret = OrderedMapList<E>.empty();
    ret._first = _first;
    ret._listElements = _listElements.map((e) => OrderedMapListEntry(value: toElement(e.value), key: e.key, nextElement: e.nextElement)).toList();
    return ret;
  }

  OrderedMapList._();

  factory OrderedMapList.empty() => OrderedMapList<T>._();

  //type factory gives the associated map (key, value) and expects an object of type T
  factory OrderedMapList.from(Map<String, dynamic>? json, Function typeFactory) {
    if(json == null || json.isEmpty) { //skip building
      return OrderedMapList<T>.empty();
    }
    var list = OrderedMapList<T>.empty();
    String? nextKey = json['_first'];
    assert(!(nextKey == null && json.isNotEmpty), 'the _first attribute is missing');

    while (nextKey != null) {
      var entry = json[nextKey];
      var val = typeFactory(key: nextKey, value: entry['value']);
      list.insert(key: nextKey, el: val);
      nextKey = entry['next'];
    }
    assert(list.size == (json.length -1), 'map references are not continuous');
    return list;
  }

  Map<String, dynamic> toJson() {
    if (size == 0) {
      assert(_first == null);
      return {};
    }
    var map = <String, dynamic>{
      '_first': _first
    };
    var previousKey = _first;
    //assert(previousKey != null, 'first attribute missing');
    for(int i = 0; i < _listElements.length; i++) {
      assert(previousKey != null, 'next attribute must be set on ${i-1} element');
      map[previousKey!] = _listElements[i].toJson();
      previousKey = _listElements[i].nextElement;
    }
    return map;
  }
}

class OrderedMapListEntry<T> extends Serializable implements Equatable {
  String? nextElement;
  String key;
  T value;
  OrderedMapListEntry({this.nextElement, required this.value, required this.key});

  @override
  Map<String, dynamic> toJson() {
    dynamic val = value;
    if (value is Serializable) {
      val = (value as Serializable).toJson();
    }
    //workaround, defining a specific serialization function would be probably better
    if (value is FormControl) {
      val = (value as FormControl).value;
    }
    return {
      'next' : nextElement,
      'value' : val,
    };
  }

  @override
  List<Object?> get props => [key];

  @override
  bool? get stringify => true;
}