import 'dart:math';

import 'package:awesome_poll_app/utils/commons.dart';
import 'package:fl_chart/fl_chart.dart';

enum ChartType {
  pie,bar,
}

class ChartTypeCubit extends Cubit<ChartType> with HydratedMixin {
  ChartTypeCubit([ChartType? initialState]) : super(initialState ?? ChartType.pie);
  setChartType(ChartType type) => emit(type);

  setType(ChartType type) => emit(type);

  @override
  ChartType? fromJson(Map<String, dynamic> json) {
    var _type = json['type'];
    if(_type != null && _type is String) {
      return ChartType.values.firstWhere((element) => element.name == _type);
    }
  }

  @override
  Map<String, dynamic>? toJson(ChartType state) => {
    'type': state.name,
  };
}


//placeholder for an empty poll
class EmptyPollResult extends StatelessWidget {
  const EmptyPollResult({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Center(
    child: Text(context.lang('poll.view.results.empty'),
        style: Theme.of(context).textTheme.headline6,
    ),
  );
}

class ChartResultLayout extends StatelessWidget {
  final Widget chart;
  final Widget legend;
  const ChartResultLayout({Key? key, required this.chart, required this.legend}) : super(key: key);
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if(constraints.maxWidth < 600) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LimitedBox(
              maxHeight: 300,
              child: chart,
            ),
            legend,
          ],
        );
      } else {
        return Row(
          children: [
            Flexible(
              flex: 4,
              child: SingleChildScrollView(
                child: legend,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              flex: 6,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: chart,
                  ),
                ),
              ),
            ),
          ],
        );
      }
    },
  );

}

//result view with a pie chart and legend
class PieChartResult extends StatelessWidget {
  final List<ChartEntry> entries;
  const PieChartResult({Key? key, required this.entries}) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Flexible(
        flex: 4,
        child: SingleChildScrollView(
          child: PollLegend(
            entries: entries,
          ),
        ),
      ),
      const SizedBox(
        width: 10,
      ),
      Flexible(
        flex: 6,
        child: Center(
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: SizedBox(
              width: 300,
              height: 300,
              child: PollPieChart(
                entries: entries,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

//an abstract representation for selectable option
class ChartEntry {
  final String title;
  final int amount;
  Color? color;
  ChartEntry(this.title, this.amount, [this.color]);
}

class PollPieChart extends StatefulWidget {
  final List<ChartEntry> entries;
  const PollPieChart({
    Key? key,
    required this.entries
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PollPieChart();
}

class _PollPieChart extends State<PollPieChart> {
  late int total = sumChartEntries(widget.entries);

  @override
  Widget build(BuildContext context) => widget.entries.isNotEmpty ? PieChart(
    PieChartData(
      sectionsSpace: 3,
      centerSpaceRadius: 0,
      sections: [
        ...widget.entries.map((e) => PieChartSectionData(
          //radius: MediaQuery.of(context).size.height/4,
          radius: 120,
          title: '${withMaxPrecision(e.amount.toDouble()/total.toDouble()*100, 2)}%',
          titleStyle: const TextStyle(
            color: Colors.white,
          ),
          value: e.amount.toDouble(),
          color: e.color ?? Theme.of(context).colorScheme.secondary,
        )),
      ],
    ),
  ) : Container();
}

class PollBarChart extends StatefulWidget {
  final List<ChartEntry> entries;
  const PollBarChart({
    Key? key,
    required this.entries,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PollBarChart();
}

class _PollBarChart extends State<PollBarChart> {
  late int total = sumChartEntries(widget.entries);
  @override
  Widget build(BuildContext context) => BarChart(
    BarChartData(
      groupsSpace: 30,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: context.theme.colorScheme.onBackground, 
          getTooltipItem: (group, groupIndex, rod, rodIndex) =>
              BarTooltipItem('${widget.entries[group.x.toInt()].title}\n Total: ${widget.entries[group.x.toInt()].amount}', TextStyle(
            color: context.theme.colorScheme.primary,
          )),
        ),
      ),
      //add 8% padding on top
      maxY: maxChartEntry(widget.entries).toDouble() * 1.08,
      titlesData: FlTitlesData(
        topTitles: SideTitles(),
        leftTitles: SideTitles(),
        bottomTitles: SideTitles(
          showTitles: true,
          getTitles: (idx) => '${withMaxPrecision(widget.entries[idx.toInt()].amount.toDouble()/total.toDouble()*100, 2)}%',
        ),
      ),
      barGroups: [
        ..._buildBars(),
      ],
    ),
  );

  Iterable<BarChartGroupData> _buildBars() sync* {
    var list = widget.entries;
    for(int i = 0; i < list.length; i++) {
      yield BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            y: list[i].amount.toDouble(),
            colors: [list[i].color ?? Theme.of(context).colorScheme.primary],
          ),
        ],
      );
    }
  }
}

class PollLegend extends StatefulWidget {
  final List<ChartEntry> entries;
  const PollLegend({
    Key? key,
    required this.entries,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PollLegend();
}

class _PollLegend extends State<PollLegend> {
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.max,
    children: [
      ...widget.entries.map((e) => ListTile(
        //mainAxisSize: MainAxisSize.min,
        leading: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: e.color ?? Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(e.title),
      )),
    ],
  );
}

///sums the total amount of votes up
int sumChartEntries(List<ChartEntry> entries) => entries.map((e) => e.amount).fold(0, (p, q) => p + q);

///returns the largest chart entry based on the amount
int maxChartEntry(List<ChartEntry> entries) => entries.map((e) => e.amount).reduce((p, q) => max(p, q));

mutatePrimaryColor(List<ChartEntry> list, [int? seed]) {
  var l = Colors.primaries.length;
  var random = Random(seed).nextInt(l);
  for(int i = 0; i < list.length; i++) {
    list[i].color = Colors.primaries[(random + i) % l];
  }
}

///rounds dynamic based on precision n, trailing '0' chars will be removed (the . included)
//e.g (0.30,2) -> 0.3, (0.1003,2) -> 0.1
String withMaxPrecision(double d, int n) {
  var dx = d.toStringAsFixed(n);
  var split = dx.split('.');
  if (split.length < 2) return dx;
  int cut = 0;
  for(int i = split[1].length-1; i >= 0; i--) {
    if(split[1].characters.characterAt(i) != '0'.characters) break;
    cut++;
  }
  var suffix = split[1].length == cut ? '' : '.${split[1].substring(0, split[1].length-cut)}';
  return '${split[0]}$suffix';
}