import 'package:awesome_poll_app/utils/commons.dart';
import 'package:awesome_poll_app/services/poll_state/poll_view.dart';
import 'package:awesome_poll_app/utils/ordered_map.dart';


///attempts to convert poll types, while preserving data between switch
//TODOthis is not very elegant, consider putting it into a map
PollQuestion _convertPollType(PollQuestion _self, PollQuestionType _new) {
  if (_self.type == _new) {
    return _self;
  }
  var id = _self.questionId;
  var fg = _self.formGroup;
  var map = _self.toJson();
  return _self.type.when(
    single: () => _new.maybeMap(
      single: (poll) {
        return PollQuestion.from(key: id, map: map, group: fg);
      },
      multiple: (poll) {
        return PollQuestion.from(key: id, map: map, group: fg, retype: PollQuestionType.multiple);
      },
      freeText: (poll) {
        return FreeTextQuestion.create(id: id, formGroup: fg);
      },
      orElse: () => throw Exception(),
    ),
    multiple: () => _new.maybeMap(
      single: (poll) {
        return PollQuestion.from(key: id, map: map, group: fg, retype: PollQuestionType.single);
      },
      multiple: (poll) {
        return PollQuestion.from(key: id, map: map, group: fg);
      },
      freeText: (poll) {
        return FreeTextQuestion.create(id: id, formGroup: fg);
      },
      orElse: () => throw Exception(),
    ),
    freeText: () => _new.maybeMap(
      single: (poll) {
        return SingleChoiceQuestion.createEmpty(id: id, formGroup: fg,);
      },
      multiple: (poll) {
        return MultipleChoiceQuestion.createEmpty(id: id, formGroup: fg,);
      },
      freeText: (poll) {
        return FreeTextQuestion.create(id: id, formGroup: fg);
      },
      orElse: () => throw Exception(),
    ),
  );
}

/// default questions for each option like question
Map<String, dynamic> _defaultOptions() {
  var first = getIt.get<API>().generateKey();
  var second = getIt.get<API>().generateKey();
  return {
    '_first': first,
    first: {
      'value': 'yes',
      'next': second,
    },
    second: {
      'value': 'no',
      'next': null,
    },
  };
}

abstract class PollQuestion implements Serializable {

  String get questionId;

  FormGroup get formGroup;

  PollQuestionType get type;

  FormControl<String> get titleControl;

  set value(Map<String, dynamic> map);
  Map<String, dynamic> get value;

  set votedValue(dynamic value);
  dynamic get votedValue;

  @override
  Map<String, dynamic> toJson() => value;

  PollQuestion convertTo(PollQuestionType type) => _convertPollType(this, type);

  static PollQuestion from({required String key, required Map<String, dynamic> map, FormGroup? group, PollQuestionType? retype}) {
    String typeVal = map['type'];
    var type = retype ?? PollQuestionType.values.firstWhere((e) => e.toString() == typeVal);
    var ret = type.when<PollQuestion>(
      single: () => SingleChoiceQuestion.create(
        id: key,
        formGroup: group ?? FormGroup({}),
        initialValues: map['options'],
      ),
      multiple: () => MultipleChoiceQuestion.create(
        id: key,
        formGroup: group ?? FormGroup({}),
        initialValues: map['options'],
      ),
      freeText: () => FreeTextQuestion.create(
        id: key,
        formGroup: group ?? FormGroup({}),
      ),
    );
    ret.titleControl.value = map['text'] ?? '';
    return ret;
  }
}

class SingleChoiceQuestion with PollQuestion {
  late String _id;
  
  String? defaultText = 'maybe';

  late final FormGroup _formGroup;

  late final FormControl<String> _titleFormField;

  final OrderedMapList<FormControl<String>> options;

  String? _selected;

  @override
  String get questionId => _id;

  @override
  FormGroup get formGroup => _formGroup;

  @override
  PollQuestionType get type => PollQuestionType.single;

  @override
  FormControl<String> get titleControl => _titleFormField;

  @override
  set value(Map<String, dynamic> map) {
    // TODO: implement value
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> get value => {
    'text': _titleFormField.value ?? '',
    'type': type.toString(),
    'options': options.toJson(),
  };

  @override
  set votedValue(dynamic value) => _selected = value;

  @override
  dynamic get votedValue => _selected;

  SingleChoiceQuestion._({required String id, required FormGroup formGroup, required this.options}) {
    _id = id;
    _formGroup = formGroup;
    var control = _formGroup.controls['text'];
    if (control != null) {
      _titleFormField = control as FormControl<String>;
      return;
    }
    _titleFormField = FormControl<String>(value: '');
    _formGroup.addAll({
      'text': _titleFormField,
    });
  }

  factory SingleChoiceQuestion.create({required String id, required FormGroup formGroup, Map<String, dynamic>? initialValues}) {
    late OrderedMapList<FormControl<String>> list;
    if (initialValues == null) {
      list = OrderedMapList<FormControl<String>>.empty();
    } else {
      list = OrderedMapList<FormControl<String>>.from(initialValues, ({required String key, required String value}) {
        var form = FormControl<String>(value: value);
        formGroup.addAll({
          key: form,
        });
        return form;
      });
    }
    return SingleChoiceQuestion._(id: id, formGroup: formGroup, options: list);
  }

  factory SingleChoiceQuestion.createEmpty({required String id, required FormGroup formGroup}) {
    return SingleChoiceQuestion.create(id: id, formGroup: formGroup);
  }

  factory SingleChoiceQuestion.createDefault({required String id, required FormGroup formGroup}) {
    return SingleChoiceQuestion.create(id: id, formGroup: formGroup, initialValues: _defaultOptions());
  }

  addOption() {
    var key = getIt.get<API>().generateKey();
    var control = FormControl<String>(value: defaultText ?? '');
    formGroup.addAll({
      key: control,
    });
    options.insert(key: key, el: control);
  }

  deleteOption(String id) {
    options.deleteByKey(id);
    formGroup.removeControl(id);
  }
}

class MultipleChoiceQuestion with PollQuestion {
  late String _id;

  String? defaultText = 'maybe';

  late final FormGroup _formGroup;

  late final FormControl<String> _titleFormField;

  final OrderedMapList<FormControl<String>> options;

  Map<String, dynamic> _selected = {};

  @override
  String get questionId => _id;

  @override
  FormGroup get formGroup => _formGroup;

  @override
  PollQuestionType get type => PollQuestionType.multiple;

  @override
  FormControl<String> get titleControl => _titleFormField;

  @override
  set value(Map<String, dynamic> map) {
    // TODO: implement value
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> get value => {
    'text': _titleFormField.value ?? '',
    'type': type.toString(),
    'options': options.toJson(),
  };

  @override
  set votedValue(dynamic value) => _selected = value;

  @override
  dynamic get votedValue => _selected;

  MultipleChoiceQuestion._({required String id, required FormGroup formGroup, required this.options}) {
    _id = id;
    _formGroup = formGroup;
    var control = _formGroup.controls['text'];
    if (control != null) {
      _titleFormField = control as FormControl<String>;
      return;
    }
    _titleFormField = FormControl<String>(value: '');
    _formGroup.addAll({
      'text': _titleFormField,
    });
  }

  factory MultipleChoiceQuestion.create({required String id, required FormGroup formGroup, Map<String, dynamic>? initialValues}) {
    late var list;
    if (initialValues == null) {
      list = OrderedMapList<FormControl<String>>.empty();
    } else {
      list = OrderedMapList<FormControl<String>>.from(initialValues, ({required String key, required String value}) {
        var form = FormControl<String>(value: value);
        formGroup.addAll({
          key: form,
        });
        return form;
      });
    }
    return MultipleChoiceQuestion._(id: id, formGroup: formGroup, options: list);
  }

  factory MultipleChoiceQuestion.createEmpty({required String id, required FormGroup formGroup}) {
    return MultipleChoiceQuestion.create(id: id, formGroup: formGroup);
  }

  factory MultipleChoiceQuestion.createDefault({required String id, required FormGroup formGroup}) {
    return MultipleChoiceQuestion.create(id: id, formGroup: formGroup, initialValues: _defaultOptions());
  }

  addOption() {
    var key = getIt.get<API>().generateKey();
    var control = FormControl<String>(value: defaultText ?? '');
    formGroup.addAll({
      key: control,
    });
    options.insert(key: key, el: control);
  }

  deleteOption(String id) {
    options.deleteByKey(id);
    formGroup.removeControl(id);
  }

  void setVotedValue(String optionId, bool val) {
    _selected[optionId] = val;
  }

  bool getVotedValue(String optionId) {
    var ret = _selected[optionId];
    ret ??= false;
    _selected[optionId] = ret;
    return ret;
  }
}


class FreeTextQuestion with PollQuestion {
  late String _id;

  late final FormGroup _formGroup;

  late final FormControl<String> _titleFormField;

  final FormControl<String> freeTextFormField = FormControl(value: '');

  @override
  String get questionId => _id;

  @override
  FormGroup get formGroup => _formGroup;

  @override
  PollQuestionType get type => PollQuestionType.freeText;

  @override
  FormControl<String> get titleControl => _titleFormField;

  @override
  set value(Map<String, dynamic> map) {
    // TODO: implement value
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> get value => {
    'text': _titleFormField.value ?? '',
    'type': type.toString(),
  };

  @override
  set votedValue(dynamic value) => freeTextFormField.value = value;

  @override
  dynamic get votedValue => freeTextFormField.value;

  FreeTextQuestion._({required String id, required FormGroup formGroup}) {
    _id = id;
    _formGroup = formGroup;
    var control = _formGroup.controls['text'];
    if (control != null) {
      _titleFormField = control as FormControl<String>;
      return;
    }
    _titleFormField = FormControl<String>(value: '');
    _formGroup.addAll({
      'text': _titleFormField,
    });
  }

  factory FreeTextQuestion.create({required String id, required FormGroup formGroup}) {
    return FreeTextQuestion._(id: id, formGroup: formGroup);
  }

  factory FreeTextQuestion.createEmpty({required String id, required FormGroup formGroup}) {
    return FreeTextQuestion.create(id: id, formGroup: formGroup);
  }
}

//TODO we probably leak memory here, since we manually create that outside the tree
//the state change should only be used when changing the question type
class PollQuestionTypeCubit extends Cubit<PollQuestionType> {
  PollQuestion question;
  PollQuestionTypeCubit(this.question) : super(question.type);

  FormControl<String> get titleControl {
    return question.titleControl;
  }

  changeType(PollQuestionType newType) {
    question = question.convertTo(newType);
    emit(newType);
  }

}
