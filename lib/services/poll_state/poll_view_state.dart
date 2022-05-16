import 'package:awesome_poll_app/utils/commons.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'poll_view_state.freezed.dart';

//different states in which a question (or the entire PollViewWidget) can be
@freezed
class ViewState with _$ViewState {
  const factory ViewState.create() = Create;

  const factory ViewState.edit({PollOverview? overview}) = Edit;

  const factory ViewState.participate({PollOverview? overview}) = Participate;

  const factory ViewState.result({PollOverview? overview}) = Result;

}

class ViewStateCubit extends Cubit<ViewState> {
  ViewStateCubit({required ViewState initial}) : super(initial);

  set state(ViewState state) => emit(state);
}
