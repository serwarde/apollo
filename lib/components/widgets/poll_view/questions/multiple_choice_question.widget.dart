import 'package:awesome_poll_app/utils/commons.dart';
import 'package:awesome_poll_app/services/poll_state/poll_view.dart';


class MultipleChoiceQuestionWidget extends StatefulWidget {
  final MultipleChoiceQuestion state;
  const MultipleChoiceQuestionWidget({Key? key, required this.state}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultipleChoiceQuestionWidget();

}

class _MultipleChoiceQuestionWidget extends State<MultipleChoiceQuestionWidget> {

  @override
  Widget build(BuildContext context) => BlocBuilder<ViewStateCubit, ViewState>(
    builder: (context, state) => state.maybeWhen(
      create: () => _buildEditableOptions(context),
      edit: (e) => _buildEditableOptions(context),
      participate: (poll) => _buildParticipationOptions(context),
      result: (poll) => _buildResult(context),
      orElse: () => const Placeholder(),
    ),
  );

  Widget _buildResult(BuildContext context) {
    return StreamBuilder(
        stream: getIt.get<API>().streamRawResults(context.read<PollFormBloc>().pollId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
          if (snapshot.data == null) {
            return const EmptyPollResult();
          }
          //accumulate results
          int total = 0;
          Map<String, int> results = {};
          var data = snapshot.data as Map<String, dynamic>;
          widget.state.options.listEntries().forEach((element) {
            results.addAll({
              element.key: 0,
            });
          });
          var els = data.values;
          for (Map<String, dynamic> el in els) {
            var option = el[widget.state.questionId];
            if (option != null && option is Map<String, dynamic>) {
              //go through inner array
              option.entries.forEach((element) {
                if(element.value) {
                  var counted = results[element.key] ?? 0;
                  results[element.key] = counted + 1;
                  total++;
                }
              });
            }
          }
          context.debug(context.lang('poll.restults.question') + ' ${widget.state.questionId}, ' + context.lang('poll.results.total_votes') + ' $total');
          var chartData = results.entries.map((e) => ChartEntry(widget.state.options.find(e.key)!.value!, e.value)).toList();
          mutatePrimaryColor(chartData, widget.state.questionId.hashCode);
          return ChartResultLayout(
            legend: PollLegend(entries: chartData),
            chart: BlocBuilder<ChartTypeCubit, ChartType>(
              builder: (context, state) {
                switch (state) {
                  case ChartType.pie:
                    return PollPieChart(entries: chartData);
                  case ChartType.bar:
                    return PollBarChart(entries: chartData);
                  default:
                    return Container();
                }
              },
            ),
          );
        }
    );
  }

  Widget _buildParticipationOptions(BuildContext context) => Column(
    children: widget.state.options
        .listEntries()
        .map<Widget>((e) => Column(
      children: [
        CheckboxListTile(
          title: Text(e.value.value ?? ''),
          value: widget.state.getVotedValue(e.key),
          onChanged: (value) {
            setState(() {
              if (value != null) widget.state.setVotedValue(e.key, value);
            });
          },
        ),
      ],
    )).toList(),
  );

  Widget _buildEditableOptions(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        children: [
          ..._buildOptionList(context),
        ],
      ),
      Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          onPressed: () => setState(() => widget.state.addOption()),
          icon: Icon(Icons.add_circle,
            color: context.theme.colorScheme.secondary,
          ),
        ),
      ),
    ],
  );

  Iterable<Widget> _buildOptionList(BuildContext context) sync* {
    for(int i = 0; i < widget.state.options.listEntries().length; i++) {
      var e = widget.state.options.listEntries()[i];
      yield _buildOptionWidget(context, e.key, e.value);
      yield const SizedBox(
        height: 4,
      );
    }
  }

  Widget _buildOptionWidget(BuildContext context, String key, FormControl<dynamic> value) {
    return Row(
      key: ObjectKey(key),
      children: [
        Expanded(
          child: ReactiveTextField(
            formControl: value,
          ),
        ),
        ExcludeFocus(
          child: IconButton(
            onPressed: () {
              setState(() {
                widget.state.deleteOption(key);
              });
            },
            icon: Icon(
              Icons.remove_circle,
              color: Theme.of(context).errorColor,
            ),
          ),
        ),
      ],
    );
  }
}