import 'package:awesome_poll_app/utils/commons.dart';
import 'package:awesome_poll_app/services/poll_state/poll_view.dart';


class FreeTextQuestionWidget extends StatelessWidget {
  final FreeTextQuestion state;
  const FreeTextQuestionWidget({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<ViewStateCubit, ViewState>(
    builder: (context, state) => state.maybeWhen(
      create: () => _buildEditable(context),
      edit: (poll) => _buildEditable(context),
      participate: (poll) => _buildParticipate(context),
      result: (poll) => _buildResult(context),
      orElse: () => const Placeholder(),
    ),
  );

  Widget _buildEditable(BuildContext context) => const TextField(enabled: false);

  Widget _buildParticipate(BuildContext context) => ReactiveTextField(
    formControl: state.freeTextFormField,
  );

  Widget _buildResult(BuildContext context) => StreamBuilder(
      stream: getIt.get<API>().streamRawResults(context.read<PollFormBloc>().pollId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
        if (snapshot.data == null) {
          return const EmptyPollResult();
        }
        var data = (snapshot.data as Map).values.toList();
        int total = data.length;
        return LimitedBox(
          maxHeight: MediaQuery.of(context).size.height / 4,
          child: Column(
            children: [
              Text(context.lang('poll.results.total_votes') + ' $total'),
              Expanded(
                child: ListView.builder(
                  itemCount: total,
                  itemBuilder: (context, index) => Text('${data[index][state.questionId]}'),
                ),
              ),
            ],
          ),
        );
      }
  );

}