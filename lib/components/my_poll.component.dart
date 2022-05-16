import 'package:awesome_poll_app/components/poll_view.component.dart';
import 'package:awesome_poll_app/utils/commons.dart';
import 'package:grouped_list/grouped_list.dart';

class MyPollComponent extends StatefulWidget {
  const MyPollComponent({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyPollComponent();
  }
}

class _MyPollComponent extends State<MyPollComponent> {
  final ScrollController _scrollController = ScrollController();
  String status =
      ''; // status for whether poll is "active", "expired", or "upcoming"

  // indicates a poll's status by color:
  // red for expired, green for active, gray for upcoming
  Color _statusColorByString(String status) {
    if (status == 'expired') {
      return const Color(0xffFFA69E);
    } else if (status == 'active') {
      return const Color(0xff2A9D8F);
    } else if (status == 'upcoming') {
      return const Color(0xff979797);
    } else {
      return const Color(0xff000000);
    }
  }

  String _status(int startTime, int endTime) {
    if (endTime.compareTo(DateTime.now().millisecondsSinceEpoch) == -1) {
      status = 'expired';
      return status;
    } else if (endTime.compareTo(DateTime.now().millisecondsSinceEpoch) == 1 &&
        startTime.compareTo(DateTime.now().millisecondsSinceEpoch) == -1) {
      status = 'active';
      return status;
    } else if (startTime.compareTo(DateTime.now().millisecondsSinceEpoch) ==
        1) {
      status = 'upcoming';
      return status;
    } else {
      return status;
    }
  }

  // subtitle of a poll differs based on status
  // active polls indicate when it ends, expired polls indicate since when it has expired,
  // upcoming polls indicate when it will start
  // all this is given in the largest unit of time currently true from days (largest) to seconds (smallest)
  // additionally, active and expired polls indicate how many people have (so far) voted in it
  String _subtitle(PollOverview item) {
    Duration active = DateTime.fromMillisecondsSinceEpoch(item.endTime)
        .difference(DateTime.now());
    Duration expired = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(item.endTime));
    Duration upcoming = DateTime.fromMillisecondsSinceEpoch(item.startTime)
        .difference(DateTime.now());

    if (_status(item.startTime, item.endTime) == 'active') {
      if (active.inDays > 1) {
        return context.lang('poll.state.active') + ' in ${active.inDays} ' + context.lang('poll.state.days');
      } else if (active.inDays == 1) {
        return context.lang('poll.state.active') + ' in ${active.inDays} ' + context.lang('poll.state.day');
      } else if (active.inHours > 1) {
        return context.lang('poll.state.active') + ' in ${active.inHours} ' + context.lang('poll.state.hours');
      } else if (active.inHours == 1) {
        return context.lang('poll.state.active') + ' in ${active.inHours} ' + context.lang('poll.state.hour');
      } else if (active.inMinutes > 1) {
        return context.lang('poll.state.active') + ' in ${active.inMinutes} ' + context.lang('poll.state.minutes');
      } else if (active.inMinutes == 1) {
        return context.lang('poll.state.active') + ' in ${active.inMinutes} ' + context.lang('poll.state.minute');
      } else if (active.inSeconds > 1) {
        return context.lang('poll.state.active') + ' in ${active.inSeconds} ' + context.lang('poll.state.seconds');
      } else if (active.inSeconds == 1) {
        return context.lang('poll.state.active') + ' in ${active.inSeconds} ' + context.lang('poll.state.second');
      }
    } else if (_status(item.startTime, item.endTime) == 'expired') {
      if (expired.inDays > 1) {
        return context.lang('poll.state.expired') + ' ${expired.inDays} ' + context.lang('poll.state.days') + ' ' + context.lang('poll.state.expired.ago');
      } else if (expired.inDays == 1) {
        return context.lang('poll.state.expired') + ' ${expired.inDays} ' + context.lang('poll.state.day') + ' ' + context.lang('poll.state.expired.ago');
      } else if (expired.inHours > 1) {
        return context.lang('poll.state.expired') + ' ${expired.inHours} ' + context.lang('poll.state.hours') + ' ' + context.lang('poll.state.expired.ago');
      } else if (expired.inHours == 1) {
        return context.lang('poll.state.expired') + ' ${expired.inHours} ' + context.lang('poll.state.hour') + '' + context.lang('poll.state.expired.ago');
      } else if (expired.inMinutes > 1) {
        return context.lang('poll.state.expired') + ' ${expired.inMinutes} ' + context.lang('poll.state.minutes') + ' ' + context.lang('poll.state.expired.ago');
      } else if (expired.inMinutes == 1) {
        return context.lang('poll.state.expired') + ' ${expired.inMinutes} ' + context.lang('poll.state.minute') + ' ' + context.lang('poll.state.expired.ago');
      } else if (expired.inSeconds > 1) {
        return context.lang('poll.state.expired') + ' ${expired.inSeconds} ' + context.lang('poll.state.seconds') + ' ' + context.lang('poll.state.expired.ago');
      } else if (expired.inSeconds == 1) {
        return context.lang('poll.state.expired') + ' ${expired.inSeconds} ' + context.lang('poll.state.second') + ' ' + context.lang('poll.state.expired.ago');
      }
    } else if (_status(item.startTime, item.endTime) == 'upcoming') {
      if (upcoming.inDays > 1) {
        return context.lang('poll.state.upcoming') + ' in ${upcoming.inDays} ' + context.lang('poll.state.days');
      } else if (upcoming.inDays == 1) {
        return context.lang('poll.state.upcoming') + ' in ${upcoming.inDays} ' + context.lang('poll.state.day');
      } else if (upcoming.inHours > 1) {
        return context.lang('poll.state.upcoming') + ' in ${upcoming.inHours} ' + context.lang('poll.state.hours');
      } else if (upcoming.inHours == 1) {
        return context.lang('poll.state.upcoming') + ' in ${upcoming.inHours} ' + context.lang('poll.state.hour');
      } else if (upcoming.inMinutes > 1) {
        return context.lang('poll.state.upcoming') + ' in ${upcoming.inMinutes} ' + context.lang('poll.state.minutes');
      } else if (upcoming.inMinutes == 1) {
        return context.lang('poll.state.upcoming') + ' in ${upcoming.inMinutes} ' + context.lang('poll.state.minute');
      } else if (upcoming.inSeconds > 1) {
        return context.lang('poll.state.upcoming') + ' in ${upcoming.inSeconds} ' + context.lang('poll.state.seconds');
      } else if (upcoming.inSeconds == 1) {
        return context.lang('poll.state.upcoming') + ' in ${upcoming.inSeconds} ' + context.lang('poll.state.second');
      }
    }
    return '';
  }

  // this function decides whether or not a poll has an 'edit' button
  // only upcoming and active polls can be edited
  Widget edit(PollOverview item) {
    TextButton button = TextButton(
      onPressed: () {
        context.router.push(PollEditRoute(pollId: item.id, overview: item));
      },
      child: const Icon(Icons.edit, color: Colors.black),
    );
    SizedBox box = const SizedBox();
    if (_status(item.startTime, item.endTime) == 'expired') {
      return box;
    }
    return button;
  }

  Color _tileColor() {
    bool _darkModeEnabled = false;

    if (Theme.of(context).brightness == Brightness.dark) {
      Color background = Theme.of(context).colorScheme.background;
      double p = 0.1;

      return Color.fromARGB(
          background.alpha,
          background.red + ((255 - background.red) * p).round(),
          background.green + ((255 - background.green) * p).round(),
          background.blue + ((255 - background.blue) * p).round());
    } else {
      Color background = Theme.of(context).colorScheme.background;
      double p = 0.9;

      return Color.fromARGB(background.alpha, (background.red * p).round(),
          (background.green * p).round(), (background.blue * p).round());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder(
            stream: getIt.get<API>().listMyPollOverviewStream(),
            builder: (streamContext, snapshot) {
              final items = <PollOverview>[];

              if (snapshot.hasData) {
                //add data from db
                var polls = snapshot.data as List<PollOverview>;
                context.debug('$polls');
                items.addAll(polls);
              } else {
                return Center(
                  child: Text(
                    context.lang('organize.no_polls'),
                  ),
                );
              }

              return GroupedListView<PollOverview, String>(
                  elements: items,
                  scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  // sorts upcoming polls by start time, expired and active polls by end time
                  itemComparator: (item1, item2) {
                    if (_status(item1.startTime, item1.endTime) == 'upcoming') {
                      return item1.startTime.compareTo(item2.startTime);
                    } else {
                      return item2.endTime.compareTo(item1.endTime);
                    }
                  },
                  // polls are grouped by status
                  groupBy: (item) => _status(item.startTime, item.endTime),
                  groupSeparatorBuilder: (value) => SizedBox(
                    height: 30,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _statusColorByString(value),
                      ),
                    ),
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  indexedItemBuilder: (_context, item, index) {
                    return InkWell(
                      onTap: () {
                        context.debug(
                            'tapped index $index , poll id: ${items[index].id}');
                        if (item.isDraft != null && item.isDraft!) {
                          context.router.push(
                              PollEditRoute(pollId: item.id, overview: item));
                          return;
                        }
                        context.router.push(PollResultRoute(
                            pollId: items[index].id, overview: items[index]));
                      },
                      onLongPress: () {
                        showDialog(context: context, builder: (context) => AlertDialog(
                          title:Text(context.lang('poll.remove')),
                          actions: [
                            SimpleDialogOption(
                              child: Text(context.lang('poll.remove_yes')),
                              onPressed: () async {
                                Navigator.pop(context);
                                await getIt.get<API>().deletePoll(item.id);
                              },
                            )
                          ],
                        ));
                      },
                      splashColor: Theme.of(context).colorScheme.secondary,
                      highlightColor: Theme.of(context).colorScheme.primary,
                      child: ListBody(children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                contentPadding: const EdgeInsets.only(left: 20),
                                leading: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: _statusColorByString(_status(
                                          item.startTime, item.endTime)),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                title: Wrap(
                                  children: [
                                    Text(item.title),
                                    if(item.isDraft != null && item.isDraft!)
                                      Chip(
                                        label: Text(context.lang('poll.draft')),
                                      ),
                                  ],
                                ),
                                subtitle: Text(_subtitle(item)),
                                trailing: edit(item),
                                tileColor:
                                    Theme.of(context).colorScheme.background,
                              ),
                            ])
                      ]),
                    );
                  });
            },
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Icon(Icons.add),
                  onPressed: () {
                    context.debug('pressed poll add button');
                    context.router.navigate(const PollCreateRoute());
                  },
                ),
              ))
        ],
      ),
    );
  }
}
