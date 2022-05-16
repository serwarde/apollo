import 'dart:async';

import 'package:awesome_poll_app/services/auth/auth.service.dart';
import 'package:awesome_poll_app/services/location/location.service.dart';
import 'package:awesome_poll_app/utils/commons.dart';
import 'package:awesome_poll_app/services/poll_state/poll_view.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_enum_annotation/functional_enum_annotation.dart';
import 'package:awesome_poll_app/utils/ordered_map.dart';

part 'poll_state.g.dart';

part 'poll_state.freezed.dart';

@functionalEnum
enum PollQuestionType { single, multiple, freeText }

//events
@freezed
class PollFormEvent with _$PollFormEvent {
  //depending on the route we either create or load a poll
  const factory PollFormEvent.createPoll() = _CreatePoll;
  const factory PollFormEvent.loadPoll(String pollId) = _LoadPoll;

  //both will try to update the used poll
  const factory PollFormEvent.publishPoll() = _PublishPoll;
  const factory PollFormEvent.savePoll() = _SavePoll;
  const factory PollFormEvent.pushResult() = _PushResult;

  //if changes are pending, this acts as a safe way to return to previous route
  const factory PollFormEvent.cancelModify({required BuildContext context}) =
      _CancelModify;

  //add/remove question
  const factory PollFormEvent.addQuestion({required PollQuestionType type}) =
      _AddQuestion;
  const factory PollFormEvent.removeQuestion({String? id}) = _DeleteQuestion;
}

//states
@freezed
abstract class PollFormState with _$PollFormState {
  //a poll without any questions
  const factory PollFormState.empty() = _PollFormEmpty;
  //poll is currently loading
  const factory PollFormState.loading() = _PollFormLoading;

  //poll fully loaded, shows loaded data
  const factory PollFormState.loaded({Poll? poll}) = _PollFormLoaded;

  //conformation for submitted poll (for participation and creation/edit)
  const factory PollFormState.submitted() = _PollFormSubmitted;

  //if submission/loading/etc... fails
  const factory PollFormState.error({required String error}) = _PollFormError;
}

//this holds the question array only
class PollFormQuestionCubit
    extends Cubit<List<OrderedMapListEntry<PollQuestionTypeCubit>>> {
  final FormGroup group;
  OrderedMapList<PollQuestionTypeCubit> items = OrderedMapList.empty();
  //TODO initial items
  PollFormQuestionCubit(
      {List<PollQuestionTypeCubit>? initialItems, required this.group})
      : super([]);

  void addQuestion(PollQuestion question) {
    items.insert(key: question.questionId, el: PollQuestionTypeCubit(question));
    group.addAll({question.questionId: question.formGroup});
    emit(items.listEntries());
  }

  bool removeQuestion(String key) {
    group.removeControl(key);
    var deleted = items.deleteByKey(key);
    emit(items.listEntries());
    return deleted;
  }

  void swap(int a, int b) {
    items.swap(a, b);
    emit(items.listEntries());
  }

  PollQuestion? forKey(String key) {
    return items.find(key)?.question;
  }

  void patchValues(Poll poll) {
    items = poll.questions.retype((e) => PollQuestionTypeCubit(e));
    items.listEntries().forEach((element) {
      group.addAll({
        element.key: element.value.question.formGroup,
      });
    });
    emit(items.listEntries());
  }

  Map<String, dynamic> answersToJson() {
    var ret = <String, dynamic>{};
    items.listEntries().forEach((element) {
      ret.addAll({
        element.key: element.value.question.votedValue,
      });
    });
    return ret;
  }
}

///state machine for handling the control flow of the poll view
class PollFormBloc extends Bloc<PollFormEvent, PollFormState> {
  static final Logger _logger = Logger.of('PollForm');
  String? _pollId;
  late FormGroup _root;
  final FormControl<String> title = FormControl<String>(value: '');
  late final FormControl<int> participants = FormControl(value: 0);
  final FormControl<int> _startTime = FormControl(value: 0);
  final FormControl<int> _endTime = FormControl(value: 0);
  final FormControl<double> longitude = FormControl(value: 8.585216);
  final FormControl<double> latitude = FormControl(value: 49.8630656);
  final FormControl<double> radius = FormControl(value: 500);
  final DateTime _initializedTime = DateTime.now();

  void _buildForm() {
    _startTime.value = _initializedTime.millisecondsSinceEpoch;
    _endTime.value =
        _initializedTime.add(const Duration(days: 1)).millisecondsSinceEpoch;
    _root = FormGroup({
      'title': title,
      'participants': participants,
      'startTime': _startTime,
      'endTime': _endTime,
      'longitude': longitude,
      'latitude': latitude,
      'radius': radius,
      'questions': questionsFormGroup,
    });
  }

  var auth = getIt.get<AuthService>();

  FormGroup get rootForm => _root;

  final FormGroup questionsFormGroup = FormGroup({});
  late final ViewStateCubit _viewState;
  late final PollFormQuestionCubit pollFormQuestionCubit =
      PollFormQuestionCubit(group: questionsFormGroup);

  Map<String, dynamic>? _snapshot;

  PollFormBloc(
      {required PollFormEvent initial, required ViewStateCubit viewState})
      : super(const PollFormState.loading()) {
    _viewState = viewState;
    _logger.debug('initial state: $initial');
    _buildForm();
    //TODO remove
    _root.valueChanges.listen((event) {
      _logger.debug('form values: $event');
    });
    on<PollFormEvent>((event, emit) async {
      _logger.debug('triggered event: $event');
      await event.maybeWhen(createPoll: () async {
        _logger.debug('create new poll');
        _updateEditable();
        emit(const PollFormState.loaded());
        add(const PollFormEvent.addQuestion(type: PollQuestionType.single));
        //@dt we don't propagate the add event fast enough to be part of the snapshot
        await Future.delayed(const Duration(milliseconds: 300));
        _snapshot = toJson();
      }, loadPoll: (pollId) async {
        _logger.debug('load poll $pollId');
        _pollId = pollId;
        emit(const PollFormState.loading());
        List<Future> loaded = [];
        loaded.add(Future.delayed(const Duration(milliseconds: 1000)));
        var poll = await getIt.get<API>().loadPoll(pollId);
        _refreshViewState(poll);
        _patchRaw(poll);
        if (_viewState.state is Edit) {
          _updateEditable();
        }
        _snapshot = toJson();
        await Future.wait(loaded);
        emit(const PollFormState.loaded());
      }, addQuestion: (pollType) {
        _logger.debug('adding poll question');
        var id = getIt.get<API>().generateKey();
        pollFormQuestionCubit.addQuestion(SingleChoiceQuestion.createDefault(
            id: id, formGroup: FormGroup({})));
      }, removeQuestion: (id) {
        if (id != null) {
          var isDeleted = pollFormQuestionCubit.removeQuestion(id);
          assert(isDeleted, 'invalid question key - can\'t remove');
        } else {
          _logger.debug('called question removal with null id');
        }
      }, publishPoll: () async {
        _logger.debug('publish poll, raw values: ${rootForm.value}');
        var api = getIt.get<API>();
        emit(const PollFormState.loading());
        var poll = _serializeUnchecked();
        await api.updatePoll(poll);
        emit(const PollFormState.submitted());
      }, pushResult: () async {
        _logger.debug('push results');
        var api = getIt.get<API>();
        await api.vote(
            pollId: _pollId!, data: pollFormQuestionCubit.answersToJson());
        api.updateDonePolls(_pollId!);
        api.fetchListPollsNearby();
        emit(const PollFormState.submitted());
      }, cancelModify: (context) {
        _logger.debug('cancel modify');
        if (context.read<ViewStateCubit>().state != const ViewState.create()) {
          context.router.navigateBack();
          return;
        }
        var _curr = toJson();
        _logger.debug('snap: $_snapshot, curr: $_curr');
        //TODO not the best place for ui code...
        if (const DeepCollectionEquality.unordered().equals(_snapshot, _curr)) {
          _logger.debug('no changes made');
          context.router.navigateBack();
          return;
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.lang('poll.state.save_changes')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(context.lang('poll.state.save_changes.question')),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(context.lang('poll.state.save_changes.discard')),
                onPressed: () {
                  Navigator.pop(context);
                  context.router.navigateBack();
                },
              ),
              TextButton(
                child: Text(context.lang('poll.state.save_changes.save')),
                onPressed: () async {
                  await getIt.get<API>().savePollDraft(_serializeUnchecked());
                  Navigator.pop(context);
                  context.router.navigateBack();
                },
              ),
            ],
          ),
        );
      }, orElse: () {
        _logger.warn('event not implemented: $event');
      });
    });
    add(initial);
  }

  String? get pollId => _pollId;

  _updateEditable() async {
    _startTime.valueChanges.listen((event) {
      assert(event != null, 'start time value is null'); // should never happen
      _endTime.value = DateTime.fromMillisecondsSinceEpoch(event!)
          .add(const Duration(hours: 1))
          .millisecondsSinceEpoch;
    });
    var location = await LocationService.getLocation();
    longitude.value = location?.longitude;
    latitude.value = location?.latitude;
  }

  @override
  Future<void> close() async {
    await pollFormQuestionCubit.close();
    return super.close();
  }

  //resolves #40
  void _refreshViewState(PollOverview p) {
    var _new = _viewState.state.whenOrNull(
      edit: (e) => ViewState.edit(overview: p),
      participate: (e) => ViewState.participate(overview: p),
      result: (e) => ViewState.result(overview: p),
    );
    if (_new != null) _viewState.emit(_new);
  }

  Poll _serializeUnchecked() {
    var poll = Poll.questionlessFromDB(
        _pollId ?? getIt.get<API>().generateKey(), rootForm.value);
    //this is not a good idea, the returned poll should be immutable
    poll.questions = pollFormQuestionCubit.items.retype((e) => e.question);
    return poll;
  }

  void _patchRaw(Poll poll) {
    var pollMap = poll.toJson();
    rootForm.patchValue(pollMap);
    pollFormQuestionCubit.patchValues(poll);
  }

  int get startTime {
    assert(_startTime.value != null, 'start time is null');
    return _startTime.value!;
  }

  int get endTime {
    assert(_endTime.value != null, 'end time is null');
    return _endTime.value!;
  }

  FormControl<int> get startTimeControl => _startTime;
  FormControl<int> get endTimeControl => _endTime;

  Map<String, dynamic> toJson() => _serializeUnchecked().toJson();
}
