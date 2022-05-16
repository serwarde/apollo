import 'dart:io';

import 'package:awesome_poll_app/components/widgets/poll_viewer.widget.dart';
import 'package:awesome_poll_app/services/auth/auth.service.dart';
import 'package:awesome_poll_app/services/location/location.service.dart';
import 'package:awesome_poll_app/utils/commons.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParticipatePollComponent extends StatefulWidget {
  const ParticipatePollComponent({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ParticipatePollComponent();
  }
}

class _ParticipatePollComponent extends State<ParticipatePollComponent> {
  final ScrollController _scrollController = ScrollController();

  var auth = getIt.get<AuthService>();
  List<String> donePolls = <String>[];
  var api = getIt.get<API>();
  String status = '';

  void updateDonePolls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList("polls") != null) {
      donePolls = prefs.getStringList("polls") as List<String>;
    }
  }

  // Determines color to indicate a poll's status based on its start time and end time
  // red for expired, green for active, gray for upcoming
  // Another status in participate is 'done' (yellow)
  // which indicates that a user has already voted in this poll
  Color _statusColor(PollOverview item) {
    if (_status(item) == 'expired') {
      return const Color(0xffFFA69E);
    } else if (_status(item) == 'active') {
      return const Color(0xff2A9D8F);
    } else if (_status(item) == 'upcoming') {
      return const Color(0xff979797);
    } else if (_status(item) == 'done') {
      return const Color(0xffFCBF49);
    } else {
      return const Color(0xff000000);
    }
  }

  // Same function as above, but the color is determined by the status which is given
  // in form of a string
  Color _statusColorByString(String status) {
    if (status == 'expired') {
      return const Color(0xffFFA69E);
    } else if (status == 'active') {
      return const Color(0xff2A9D8F);
    } else if (status == 'upcoming') {
      return const Color(0xff979797);
    } else if (status == 'done') {
      return const Color(0xffFCBF49);
    } else {
      return const Color(0xff000000);
    }
  }

  // This function returns the status of a poll in form of a string
  String _status(PollOverview item, {bool ignoreDone = false}) {
    if (api.isPollDone(item.id) && !ignoreDone) {
      status = 'done';
      return status;
    } else if (item.endTime.compareTo(DateTime.now().millisecondsSinceEpoch) ==
        -1) {
      status = 'expired';
      return status;
    } else if (item.endTime.compareTo(DateTime.now().millisecondsSinceEpoch) ==
            1 &&
        item.startTime.compareTo(DateTime.now().millisecondsSinceEpoch) == -1) {
      status = 'active';
      return status;
    } else if (item.startTime
            .compareTo(DateTime.now().millisecondsSinceEpoch) ==
        1) {
      status = 'upcoming';
      return status;
    } else {
      return status;
    }
  }

  // Same function as in my_poll.component except that participate_poll.component does not
  // show expired polls, therefore they do not need a subtitle
  String _subtitle(PollOverview item) {
    Duration active = DateTime.fromMillisecondsSinceEpoch(item.endTime)
        .difference(DateTime.now());
    Duration upcoming = DateTime.fromMillisecondsSinceEpoch(item.startTime)
        .difference(DateTime.now());

    if (_status(item, ignoreDone: true) == 'active') {
      if (active.inDays > 1) {
        return context.lang('poll.state.active') +
            ' in ${active.inDays} ' +
            context.lang('poll.state.days');
      } else if (active.inDays == 1) {
        return context.lang('poll.state.active') +
            ' in ${active.inDays} ' +
            context.lang('poll.state.day');
      } else if (active.inHours > 1) {
        return context.lang('poll.state.active') +
            ' in ${active.inHours} ' +
            context.lang('poll.state.hours');
      } else if (active.inHours == 1) {
        return context.lang('poll.state.active') +
            ' in ${active.inHours} ' +
            context.lang('poll.state.hour');
      } else if (active.inMinutes > 1) {
        return context.lang('poll.state.active') +
            ' in ${active.inMinutes} ' +
            context.lang('poll.state.minutes');
      } else if (active.inMinutes == 1) {
        return context.lang('poll.state.active') +
            ' in ${active.inMinutes} ' +
            context.lang('poll.state.minute');
      } else if (active.inSeconds > 1) {
        return context.lang('poll.state.active') +
            ' in ${active.inSeconds} ' +
            context.lang('poll.state.seconds');
      } else if (active.inSeconds == 1) {
        return context.lang('poll.state.active') +
            ' in ${active.inSeconds} ' +
            context.lang('poll.state.second');
      }
    } else if (_status(item, ignoreDone: true) == 'upcoming') {
      if (upcoming.inDays > 1) {
        return context.lang('poll.state.upcoming') +
            ' in ${upcoming.inDays} ' +
            context.lang('poll.state.days');
      } else if (upcoming.inDays == 1) {
        return context.lang('poll.state.upcoming') +
            ' in ${upcoming.inDays} ' +
            context.lang('poll.state.day');
      } else if (upcoming.inHours > 1) {
        return context.lang('poll.state.upcoming') +
            ' in ${upcoming.inHours} ' +
            context.lang('poll.state.hours');
      } else if (upcoming.inHours == 1) {
        return context.lang('poll.state.upcoming') +
            ' in ${upcoming.inHours} ' +
            context.lang('poll.state.hour');
      } else if (upcoming.inMinutes > 1) {
        return context.lang('poll.state.upcoming') +
            ' in ${upcoming.inMinutes} ' +
            context.lang('poll.state.minutes');
      } else if (upcoming.inMinutes == 1) {
        return context.lang('poll.state.upcoming') +
            ' in ${upcoming.inMinutes} ' +
            context.lang('poll.state.minute');
      } else if (upcoming.inSeconds > 1) {
        return context.lang('poll.state.upcoming') +
            ' in ${upcoming.inSeconds} ' +
            context.lang('poll.state.seconds');
      } else if (upcoming.inSeconds == 1) {
        return context.lang('poll.state.upcoming') +
            ' in ${upcoming.inSeconds} ' +
            context.lang('poll.state.second');
      }
    }
    return '';
  }

  // When an active poll is clicked, the user is either taken to the screen where they
  // can participate in the poll, or to the poll's results
  // This is decided by whether or not the user has participated in this poll already
  void _changeContext(PollOverview item) {
    if (!api.isPollDone(item.id)) {
      context.router
          .push(PollParticipateRoute(pollId: item.id, overview: item));
    } else {
      context.router.push(PollResultRoute(pollId: item.id, overview: item));
    }
  }

  // Users can update their vote by clicking on the edit button
  // This button only exists for polls that the user has participated in
  Widget editButton(PollOverview item) {
    TextButton button = TextButton(
      onPressed: () {
        context.router
            .push(PollParticipateRoute(pollId: item.id, overview: item));
      },
      child: const Icon(Icons.edit, color: Colors.black),
    );
    SizedBox box = const SizedBox();
    if (_status(item) != 'done') {
      return box;
    } else if (_status(item) == 'done' &&
        _status(item, ignoreDone: true) == 'expired') {
      return box;
    }
    return button;
  }

  List<PollOverviewLocation>? _latestItems;

  @override
  Widget build(BuildContext context) {
    // Trigger an initial load of the nearby polls list.
    getIt.get<API>().fetchListPollsNearby();

    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => getIt.get<API>().fetchListPollsNearby(),
            child: ValueListenableBuilder(
                valueListenable: getIt.get<API>().nearbyPolls,
                builder: (BuildContext context, List<PollOverviewLocation>? nearbyPolls,
                    Widget? child) {
                  if (nearbyPolls != null) {
                    final items = <PollOverviewLocation>[];

                    if (nearbyPolls.isNotEmpty) {
                      //add data from db
                      for (PollOverviewLocation item in nearbyPolls) {
                        if (_status(item) != 'expired') {
                          items.add(item);
                        } //only add polls that aren't expired
                      }
                      //items.addAll(polls);
                    }
                    _latestItems = nearbyPolls;

                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          context.lang('participate.noPollsNearby'),
                        ),
                      );
                    }
                    return polls_list(items, context);
                  } else {
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Center(child: CircularProgressIndicator()),
                          const SizedBox(height: 10),
                          Center(
                              child: Text(
                                  context.lang('participate.GPSMustBeEnabled')))
                        ]);
                  }
                }),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.onBackground,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  color: Theme.of(context).colorScheme.background,
                  icon: const Icon(Icons.pin_drop),
                  onPressed: () async {
                    var location = await LocationService.getLocation();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FutureBuilder(
                      future: getIt.get<API>().fetchListPolls(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) return Container();
                        var data = snapshot.data as List<PollOverviewLocation>?;
                        return PollViewerWidget(
                          //TODO throw instead of showing 0/0 location
                          lat: location?.latitude ?? 0,
                          lng: location?.longitude ?? 0,
                          initialZoom: 16,
                          minZoom: 8,
                          maxZoom: 20,
                          polls: data ?? [],
                        );
                      }
                    )));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  GroupedListView<PollOverview, String> polls_list(
      List<PollOverview> items, BuildContext context) {
    return GroupedListView<PollOverview, String>(
        elements: items,
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        itemComparator: (item1, item2) {
          if (_status(item1) == 'upcoming') {
            return item1.startTime.compareTo(item2.startTime);
          } else {
            return item2.endTime.compareTo(item1.endTime);
          }
        },
        groupBy: (item) => _status(item),
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () => {
                if (_status(item) != 'upcoming')
                  {
                    _changeContext(item),
                  },
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
                            color: _statusColor(item),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      title: Text(item.title),
                      subtitle: Text(_subtitle(item)),
                      trailing: editButton(item),
                      tileColor: Theme.of(context).colorScheme.background,
                    ),
                  ],
                )
              ]),
            ),
          );
        });
  }
}
