import 'package:awesome_poll_app/components/widgets/location_picker.widget.dart';
import 'package:awesome_poll_app/services/location/location.service.dart';
import 'package:awesome_poll_app/utils/commons.dart';
import 'package:awesome_poll_app/services/poll_state/poll_view.dart';
import 'package:awesome_poll_app/utils/ordered_map.dart';
import 'package:google_geocoding/google_geocoding.dart';

//poll view and all it's child widgets are defining the entire layout
//this includes create/edit,participate & result view
//see poll_state.dart for flow control
class PollViewLayoutWidget extends StatelessWidget {
  const PollViewLayoutWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              //TODO do the context eval here
              context
                  .read<PollFormBloc>()
                  .add(PollFormEvent.cancelModify(context: context));
            },
          ),
          actions: [
            BlocBuilder<ViewStateCubit, ViewState>(
              builder: (context, state) => state.maybeWhen(
                result: (_) => IconButton(
                  icon: const Icon(Icons.poll),
                  onPressed: () async {
                    ChartType? result = await showDialog(
                        context: context,
                        builder: (context) => SimpleDialog(
                              title: Text(
                                  context.lang('poll.view.results.chart-type')),
                              children: [
                                SimpleDialogOption(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.pie_chart,
                                        color: context
                                            .theme.colorScheme.onBackground,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(context
                                          .lang('poll.view.results.pie-chart')),
                                    ],
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(context, ChartType.pie),
                                ),
                                SimpleDialogOption(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.bar_chart,
                                        color: context
                                            .theme.colorScheme.onBackground,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(context
                                          .lang('poll.view.results.bar-chart')),
                                    ],
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(context, ChartType.bar),
                                ),
                              ],
                            ));
                    if (result != null) {
                      context.read<ChartTypeCubit>().setType(result);
                    }
                  },
                ),
                orElse: () => Container(),
              ),
            ),
          ],
          elevation: 3,
          title: BlocBuilder<ViewStateCubit, ViewState>(
            builder: (context, state) => state.when(
              create: () => Text(context.lang('poll.view.title.create')),
              //TODO `active` at end is kinda wrong
              edit: (overview) => Text(
                  '${overview?.title} - ${overview!.startTime < DateTime.now().millisecondsSinceEpoch ? context.lang('poll.view.title.active') : context.lang('poll.view.title.upcoming')}'),
              participate: (overview) =>
                  Text(context.lang('poll.view.title.participate')),
              result: (overview) => Text(
                  '${overview?.title} ${context.lang('poll.view.title.result')}'),
            ),
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocProvider(
                create: (context) => BlocProvider.of<PollFormBloc>(context)
                    .pollFormQuestionCubit,
                child: BlocBuilder<PollFormQuestionCubit,
                    List<OrderedMapListEntry<PollQuestionTypeCubit>>>(
                  builder: (context, state) => ListView(
                    //buildDefaultDragHandles: false,
                    children: [
                      _buildHeader(context),
                      //quickfix for missing ancestor provider
                      ...state.map((e) {
                        return _toPollWidget(context, e);
                      }).toList(),
                      Align(
                        key: UniqueKey(),
                        alignment: Alignment.center,
                        child: BlocBuilder<ViewStateCubit, ViewState>(
                          builder: (context, state) => state.maybeWhen(
                              create: () => _buildQuestionAddButton(context),
                              edit: (poll) => _buildQuestionAddButton(context),
                              orElse: () => Container()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //publish button
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: BlocBuilder<ViewStateCubit, ViewState>(
                  builder: (context, state) => state.maybeWhen(
                    create: () => _buildActionButton(
                      context: context,
                      text: context.lang('poll.view.actions.publish'),
                      color: Theme.of(context).colorScheme.error,
                      action: const PollFormEvent.publishPoll(),
                    ),
                    edit: (poll) => _buildActionButton(
                      context: context,
                      text: context.lang('poll.view.actions.update'),
                      color: Theme.of(context).colorScheme.error,
                      action: const PollFormEvent.publishPoll(),
                    ),
                    participate: (poll) => _buildActionButton(
                      context: context,
                      text: context.lang('poll.view.actions.vote'),
                      color: Theme.of(context).colorScheme.error,
                      action: const PollFormEvent.pushResult(),
                    ),
                    orElse: () => Container(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildActionButton(
          {required BuildContext context,
          required PollFormEvent action,
          required String text,
          Color? color}) =>
      ElevatedButton(
        onPressed: () {
          context.read<PollFormBloc>().add(action);
        },
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          )),
          backgroundColor: MaterialStateProperty.all<Color>(
              color ?? Theme.of(context).colorScheme.primary),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(text),
        ),
      );

  Widget _buildHeader(BuildContext context) => Column(
        children: [
          //title
          BlocBuilder<ViewStateCubit, ViewState>(
            builder: (context, state) {
              Widget? leading;
              if (state is Create || state is Edit) {
                leading = Text(
                  context.lang('poll.view.fields.title'),
                  style: Theme.of(context).textTheme.subtitle1,
                );
              }
              return PollQuestionStyleWidget(
                leading: leading,
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.headline5!,
                  child: BlocBuilder<ViewStateCubit, ViewState>(
                    builder: (context, state) => state.maybeWhen(
                      participate: (poll) => Text('${poll?.title}'),
                      result: (poll) => Text('${poll?.title}'),
                      orElse: () => ReactiveTextField(
                        formControl:
                            BlocProvider.of<PollFormBloc>(context).title,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          //date
          BlocBuilder<ViewStateCubit, ViewState>(
            builder: (context, state) => state.maybeWhen(
              create: () => Column(
                children: [
                  PollQuestionStyleWidget(
                    leading: Text(context.lang('poll.view.fields.time.start')),
                    child: PollViewDateWidget(
                      timestampControl:
                          context.read<PollFormBloc>().startTimeControl,
                    ),
                  ),
                  PollQuestionStyleWidget(
                    leading: Text(context.lang('poll.view.fields.time.end')),
                    child: PollViewDateWidget(
                      timestampControl:
                          context.watch<PollFormBloc>().endTimeControl,
                      minStartTime: DateTime.now(),
                    ),
                  ),
                ],
              ),
              orElse: () => PollQuestionStyleWidget(
                child: Row(
                  children: [
                    Text('${context.lang('poll.view.fields.time.start')}:'),
                    Text(DateTime.fromMillisecondsSinceEpoch(
                            context.read<PollFormBloc>().startTime)
                        .format),
                    Expanded(child: Container()),
                    Text('${context.lang('poll.view.fields.time.end')}:'),
                    Text(DateTime.fromMillisecondsSinceEpoch(
                            context.read<PollFormBloc>().endTime)
                        .format),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          BlocBuilder<ViewStateCubit, ViewState>(
            builder: (context, state) => state.maybeWhen(
              create: () => PollQuestionStyleWidget(
                  onTap: () async {
                    var userLocation = await LocationService.getLocation();
                    var location = await Navigator.push<CircleLocation?>(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LocationPickerWidget(
                                  lat: userLocation?.latitude ?? 0,
                                  lng: userLocation?.longitude ?? 0,
                                  zoom: 16,
                                  minZoom: 8,
                                  maxZoom: 20,
                                )));
                    context.debug('actually: $location');
                    if (location != null) {
                      var form = context.read<PollFormBloc>();
                      form.longitude.value = location.longitude;
                      form.latitude.value = location.latitude;
                      form.radius.value = location.radius;
                    }
                  },
                  leading: const Icon(Icons.location_on),
                  child: StreamBuilder(
                    //TODO shouln't be here, not typesafe
                    stream: context.read<PollFormBloc>().rootForm.valueChanges,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var data = snapshot.data as Map<String, dynamic>;
                        //Add your Google API Key here:
                        var googleGeocoding =
                            GoogleGeocoding('#GOOGLE-API-Key');
                        var _default = Text(
                            'Long: ${data['longitude']} Lat: ${data['latitude']} Rad: ${data['radius']}');
                        return FutureBuilder(
                          future: googleGeocoding.geocoding.getReverse(
                              LatLon(data['latitude'], data['longitude'])),
                          initialData: _default,
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data != null &&
                                snapshot.data is GeocodingResponse?) {
                              var _data = snapshot.data as GeocodingResponse?;
                              //TODO null handling
                              return Text(
                                  '${_data?.results?.first.formattedAddress} within ${(data['radius'] as double).toInt()} meters');
                            }
                            return _default;
                          },
                        );
                      }
                      return const Text('-');
                    },
                  )),
              orElse: () => Container(),
            ),
          ),
        ],
      );

  Widget _buildQuestionAddButton(BuildContext context) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.onBackground,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          color: Theme.of(context).colorScheme.background,
          icon: const Icon(Icons.add),
          onPressed: () => BlocProvider.of<PollFormBloc>(context).add(
              const PollFormEvent.addQuestion(type: PollQuestionType.single)),
        ),
      );

  //TODO doesn't seem to be working
  //quickfix for https://github.com/flutter/flutter/issues/88570, we just copy all necessary providers for each item...
  Widget _toPollWidget(BuildContext context,
          OrderedMapListEntry<PollQuestionTypeCubit> entry) =>
      Container(
        key: ObjectKey(entry.key),
        child: Column(
          children: [
            PollQuestionStyleWidget(
              child: Divider(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            BlocProvider<PollQuestionTypeCubit>(
              create: (context) => entry.value,
              child: PollQuestionControlWidget(
                id: entry.key,
              ),
            ),
          ],
        ),
      );
}

class PollQuestionControlWidget extends StatefulWidget {
  final String id;
  const PollQuestionControlWidget({Key? key, required this.id})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _PollQuestionControlWidget();
}

class _PollQuestionControlWidget extends State<PollQuestionControlWidget> {
  bool _preview = false;
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ViewStateCubit>(
      key: UniqueKey(),
      create: (_context) {
        if (_preview) {
          return ViewStateCubit(initial: const ViewState.participate());
        }
        //@dt this can become a problem, since we copy only the state, if changes to it occur, they wont propagate to the question
        return ViewStateCubit(initial: context.read<ViewStateCubit>().state);
      },
      child: PollQuestionStyleWidget(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              //question controls
              Row(
                children: [
                  Expanded(
                    child: BlocBuilder<ViewStateCubit, ViewState>(
                      builder: (context, state) => state.maybeWhen(
                        create: () => _buildTitleControl(context),
                        edit: (e) => _buildTitleControl(context),
                        orElse: () => Text(
                          context
                                  .read<PollQuestionTypeCubit>()
                                  .titleControl
                                  .value ??
                              '',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    ),
                  ),
                  //preview
                  BlocBuilder<ViewStateCubit, ViewState>(
                    builder: (context, state) => state.maybeWhen(
                      create: () => _showPreview(),
                      edit: (e) => _showPreview(),
                      orElse: () => Container(),
                    ),
                  ),
                  //type
                  BlocBuilder<ViewStateCubit, ViewState>(
                    builder: (context, state) => state.maybeWhen(
                      create: () => _buildTypeSelector(context),
                      edit: (e) => _buildTypeSelector(context),
                      orElse: () => Container(),
                    ),
                  ),
                  if (_preview) _showPreview(),
                  BlocBuilder<ViewStateCubit, ViewState>(
                    builder: (context, state) => state.maybeWhen(
                      create: () => _buildMoreVertOptions(context),
                      edit: (e) => _buildMoreVertOptions(context),
                      orElse: () => Container(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              //actual question
              BlocBuilder<PollQuestionTypeCubit, PollQuestionType>(
                builder: (context, state) {
                  var question = BlocProvider.of<PollFormQuestionCubit>(context)
                      .forKey(widget.id);
                  return state.maybeWhen<Widget>(
                    single: () => SingleChoiceQuestionWidget(
                        state: question as SingleChoiceQuestion),
                    multiple: () => MultipleChoiceQuestionWidget(
                        state: question as MultipleChoiceQuestion),
                    freeText: () => FreeTextQuestionWidget(
                        state: question as FreeTextQuestion),
                    orElse: () => const Placeholder(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleControl(BuildContext context) => ReactiveTextField(
        formControl: context.read<PollQuestionTypeCubit>().titleControl,
      );

  Widget _buildMoreVertOptions(BuildContext context) => PopupMenuButton(
        icon: const Icon(Icons.more_vert),
        itemBuilder: (context) => [
          //_buildMoveControl(context, context.lang('poll.view.actions.move_up'),
          //    (idx) => --idx),
          //_buildMoveControl(context,
          //    context.lang('poll.view.actions.move_down'), (idx) => ++idx),
          PopupMenuItem(
            child: Text(context.lang('poll.view.actions.delete')),
            onTap: () {
              BlocProvider.of<PollFormBloc>(context)
                  .add(PollFormEvent.removeQuestion(id: widget.id));
            },
          ),
        ],
      );

  PopupMenuItem _buildMoveControl(
      BuildContext context, String text, int Function(int) op) {
    var question = context.read<PollFormQuestionCubit>();
    var _this = question.items.findIndex(widget.id);
    var _next = op(_this!);
    return PopupMenuItem(
      enabled: _next >= 0 && _next < question.items.size,
      child: Text(text),
      onTap: () => question.swap(_this, _next),
    );
  }

  Widget _buildTypeSelector(BuildContext context) => IconButton(
        icon: BlocBuilder<PollQuestionTypeCubit, PollQuestionType>(
          builder: (context, state) => state.when(
              single: () => const Icon(Icons.radio_button_checked),
              multiple: () => const Icon(Icons.check_box),
              freeText: () => const Icon(Icons.notes)),
        ),
        onPressed: () async {
          var type = await showDialog<PollQuestionType?>(
            context: context,
            builder: (context) => SimpleDialog(
              title: Text(context.lang('poll.view.fields.question_type')),
              children: [
                SimpleDialogOption(
                  child: Text(
                      context.lang('poll.view.fields.question_type.single')),
                  onPressed: () =>
                      Navigator.pop(context, PollQuestionType.single),
                ),
                SimpleDialogOption(
                  child: Text(
                      context.lang('poll.view.fields.question_type.multiple')),
                  onPressed: () =>
                      Navigator.pop(context, PollQuestionType.multiple),
                ),
                SimpleDialogOption(
                  child: Text(
                      context.lang('poll.view.fields.question_type.free_text')),
                  onPressed: () =>
                      Navigator.pop(context, PollQuestionType.freeText),
                ),
              ],
            ),
          );
          if (type != null) {
            context.read<PollQuestionTypeCubit>().changeType(type);
          }
        },
      );

  Widget _showPreview() => IconButton(
        icon: _preview
            ? const Icon(Icons.visibility)
            : const Icon(Icons.visibility_off),
        onPressed: () {
          setState(() {
            _preview = !_preview;
          });
        },
      );
}

class PollQuestionStyleWidget extends StatelessWidget {
  final Widget? leading;
  final Widget child;
  final Color? color;
  final GestureTapCallback? onTap;
  const PollQuestionStyleWidget({
    Key? key,
    required this.child,
    this.leading,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        tileColor: color,
        leading: leading,
        title: Align(
          alignment: Alignment.centerLeft,
          child: child,
        ),
      );
}
