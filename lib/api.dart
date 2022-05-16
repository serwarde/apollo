import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:awesome_poll_app/utils/commons.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_database/firebase_database.dart';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;

import 'package:awesome_poll_app/config/env.dart';
import 'package:awesome_poll_app/db.dart';
import 'package:awesome_poll_app/injectable.dart';
import 'package:awesome_poll_app/services/auth/auth.service.dart';
import 'package:awesome_poll_app/services/location/location.service.dart';
import 'package:awesome_poll_app/notification_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
/*
 * TODO use api as interface, allow easy emulator switch
 */

@firebase
@LazySingleton()
class API {
  static Logger logger = Logger.of('API');
  static const String pathUser = 'users';
  static const String pathOverview = 'poll-overview';
  static const String pathPollDetails = 'poll-details';
  static const String pathPolls = 'polls';
  static const String pathAnswers = 'poll-results';

  late DatabaseReference root;

  late DatabaseReference userPreferences;
  late DatabaseReference userPolls;
  late DatabaseReference pollDetails;
  late DatabaseReference pollLocations;
  late DatabaseReference pollResults;
  late String serverUrl;

  ValueNotifier<List<PollOverviewLocation>?> nearbyPolls = ValueNotifier(null);

  final List<Future> _initializers = [];
  List<String> donePolls = <String>[];
  late SharedPreferences prefs;

  API() {
    root = FirebaseDatabase(
            databaseURL:
                'https://awesome-poll-app-default-rtdb.europe-west1.firebasedatabase.app/')
        .reference();
    //root = FirebaseDatabase(databaseURL: 'http://127.0.0.1:9000/?ns=awesome-poll-app').reference();
    pollDetails = root.child(pathPollDetails);
    pollLocations = root.child(pathPolls);
    pollResults = root.child(pathAnswers);
    var assetsLoaded = loadAssets();
    _initializers.add(assetsLoaded);

    var auth = getIt.get<AuthService>();
    auth.uidChanges.listen(updateUserStreams);
    loadSharedPrefs();
  }

  updateUserStreams(uid) {
    userPreferences = root.child('$pathUser/$uid');
    userPolls = root.child('$pathOverview/$uid');
  }

  loadAssets() async {
    serverUrl = await rootBundle.loadString('assets/serverurl.txt');
  }

  Future<void> loadSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    List<String> donePolls = <String>[];
    if (prefs.getStringList("polls") != null) {
      donePolls = prefs.getStringList("polls") as List<String>;
    }
  }

  void updateDonePolls(String pollID) {
    donePolls.add(pollID);
    prefs.setStringList("polls", donePolls);
  }

  bool isPollDone(String pollID) {
    return donePolls.contains(pollID);
  }

  ///list of poll overviews of logged in user
  Stream<List<PollOverview>> listMyPollOverviewStream() async* {
    await initialized;
    yield* userPolls.onValue.map((e) => _toMap(e.snapshot.value)
        .entries
        .map((el) => PollOverview.fromDB(el.key, el.value))
        .toList());
  }

  ///updates all necessary entries within the database for an existing poll
  Future<void> updatePoll(Poll poll) async {
    await initialized;
    //TODO transactional/batch write
    var of = userPolls.child(poll.id).set(poll.toJsonPollOverview());
    var lf =
        pollLocations.child(poll.id).set(poll.toJsonPollOverviewLocation());
    var df = pollDetails.child(poll.id).set(poll.toJson());
    await Future.wait([of, lf, df]);
  }

  Future<void> savePollDraft(Poll poll) async {
    await initialized;
    //TODO transactional/batch write
    poll.isDraft = true;
    var of = userPolls.child(poll.id).set(poll.toJsonPollOverview());
    var df = pollDetails.child(poll.id).set(poll.toJson());
    await Future.wait([of, df]);
  }

  Future<void> deletePoll(String id) async {
    await initialized;
    //TODO transactional
    var of = userPolls.child(id).remove();
    var lf = pollLocations.child(id).remove();
    var df = pollDetails.child(id).remove();
    var rf = pollResults.child(id).remove();
    await Future.wait([of, lf, df, rf]);
  }

  Future<void> updatePollOverview(PollOverview poll) async {
    await initialized;
    return await userPolls.child(poll.id).set(poll.toJsonPollOverview());
  }

  Future<Poll> loadPoll(String pollId) async {
    await initialized;
    var snapshot = await pollDetails.child(pollId).get();
    return Poll.fromDB(pollId, _toMap(snapshot.value));
  }

  Future<List<PollOverview>> listPollsNearby(double longitude, latitude) async {
    await initialized;
    var snapshot = await pollLocations.get();
    //TODO filter, do filtering as a function
    return Map.from(_toMap(snapshot.value))
        .entries
        .map((e) => PollOverviewLocation.fromDB(e.key, e.value))
        .toList();
  }

  /// Request a list of all polls available in the nearby region.
  /// This also trigger an update of the participate screen by changing the nearbyPolls ValueNotifier.
  fetchListPollsNearby() async {
    await initialized;
    // Load location
    LocationData? locationData = await LocationService.getLocation();
    if (locationData == null ||
        locationData.longitude == null ||
        locationData.latitude == null) {
      // set the value of nearbyPolls to null to indicate, that it could not be fetched
      nearbyPolls.value = null;
      return;
    }

    // Also update the location for the notification service here
    NotificationHandler.updateLocation(
        locationData.latitude!, locationData.longitude!);

    // Fetch poll list from backend
    var auth = getIt.get<AuthService>();
    Uri url = Uri.parse(serverUrl +
        '/api/listPollsNearby?longitude=' +
        locationData.longitude.toString() +
        '&latitude=' +
        locationData.latitude.toString());
    try {
      final response = await http
          .get(url, headers: {"authorization": await auth.getUserTokenId()});

      if (response.statusCode == 200) {
        nearbyPolls.value =
            Map<String, dynamic>.from(json.decode(response.body))
                .entries
                .map((el) => PollOverviewLocation.fromDB(el.key, el.value))
                .toList();
      } else {
        nearbyPolls.value = null;
        throw Exception("Could not fetch polls from Backend");
      }
    } catch (e) {
      throw Exception("Could not fetch polls from Backend");
    }
  }


  Future<List<PollOverviewLocation>> fetchListPolls() async {
    await initialized;

    // Fetch poll list from backend
    var auth = getIt.get<AuthService>();
    Uri url = Uri.parse('$serverUrl/api/listPollsMap');
    try {
      final response = await http.get(url, headers: {"authorization": await auth.getUserTokenId()});
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body))
                .entries
                .map((el) => PollOverviewLocation.fromDB(el.key, el.value))
                .toList();
      } else {
        throw Exception("Could not fetch polls from Backend");
      }
    } catch (e) {
      throw Exception("Could not fetch polls from Backend");
    }
  }

  Future<void> vote(
      {required String pollId, required Map<String, dynamic> data}) async {
    //TODO stricter typing
    String hID = await hashedID(pollId);
    await pollResults.child(pollId).child(hID).update(data);
  }

  ///returns raw db voting entries, grouped by hashed uid
  Future<Map<String, dynamic>> rawResults(String pollId) async {
    await initialized;
    return _toMap((await pollResults.child(pollId).get()).value);
  }

  Stream<Map<String, dynamic>> streamRawResults(String pollId) async* {
    await initialized;
    yield* pollResults
        .child(pollId)
        .onValue
        .map((event) => _toMap(event.snapshot.value));
  }

  bool _isInReach(
      PollOverviewLocation poll, double longitude, double latitude) {
    const double earthPerimeter = 40030 * 1000; // in meters
    return pow((longitude - poll.longitude), 2) +
            pow((latitude - poll.latitude), 2) <
        pow(poll.radius / earthPerimeter * 360, 2);
  }

  String generateKey({dynamic any}) => root.push().key!;

  // String get _uid {
  //   var auth = getIt.get<AuthService>();
  //   logger.info('api bound to user: ${auth.uid}');
  //   return auth.uid;
  // }

  Future<String> hashedID(String pollId) async {
    var auth = getIt.get<AuthService>();
    return await auth.hashedID(pollId);
  }

  Future<void> get initialized {
    var auth = getIt.get<AuthService>().initialized;
    return Future.wait([auth, ..._initializers]);
  }

  //TODO that's just stupid
  Map<String, dynamic> _toMap(dynamic any) => jsonDecode(jsonEncode(any));
}
