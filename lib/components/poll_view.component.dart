import 'package:awesome_poll_app/utils/commons.dart';
import 'package:awesome_poll_app/services/poll_state/poll_view.dart';

class PollCreateComponent extends StatelessWidget {
  const PollCreateComponent({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => PollViewWidget(initial: const PollFormEvent.createPoll()); 
}

class PollEditComponent extends StatelessWidget {
  final String pollId;
  final PollOverview? overview;
  const PollEditComponent({Key? key, @PathParam('pollId') required this.pollId, this.overview}) : super(key: key);
  @override
  Widget build(BuildContext context) => PollViewWidget(
    initial: PollFormEvent.loadPoll(pollId),
    initialViewState: ViewState.edit(overview: overview),
  );
}

class PollParticipateComponent extends StatelessWidget {
  final String pollId;
  final PollOverview? overview;
  const PollParticipateComponent({Key? key, @PathParam('pollId') required this.pollId, this.overview}) : super(key: key);
  @override
  Widget build(BuildContext context) => PollViewWidget(
    initial: PollFormEvent.loadPoll(pollId),
    initialViewState: ViewState.participate(overview: overview),
  );
}

class PollResultComponent extends StatelessWidget {
  final String pollId;
  final PollOverview? overview;
  const PollResultComponent({Key? key, @PathParam('pollId') required this.pollId, this.overview}) : super(key: key);
  @override
  Widget build(BuildContext context) => PollViewWidget(
    initial: PollFormEvent.loadPoll(pollId),
    initialViewState: ViewState.result(overview: overview),
  );
}
