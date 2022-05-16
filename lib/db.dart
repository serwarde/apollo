import 'package:awesome_poll_app/utils/ordered_map.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:awesome_poll_app/services/poll_state/poll_question.dart';

part 'db.g.dart';

//since we cant define a static constructor method/factory we need to manually
// define a callback to reconstruct the object, see
//https://stackoverflow.com/questions/56484370
//https://github.com/dart-lang/language/issues/647
abstract class Serializable<T> {
  //no from fromJson() method here...
  Map<String, dynamic> toJson();
}

@JsonSerializable()
class PollOverview {
  String id;
  String title;
  int startTime, endTime;
  int? participants;
  bool? isDraft;

  PollOverview(this.id, this.title, this.startTime, this.endTime, this.participants, [this.isDraft = false]);

  factory PollOverview.from(
      {required String id,
      required String title,
      required int startTime,
      required int endTime,
      required int participants}) {
    return PollOverview(id, title, startTime, endTime, participants);
  }

  factory PollOverview.fromDB(String pollId, Map<String, dynamic> json) {
    var map = Map<String, dynamic>.from(json);
    map['id'] = pollId;
    return PollOverview.fromJson(map);
  }

  //currently alias, might strip some fields in here
  Map<String, dynamic> toDB() => toJson();

  factory PollOverview.fromJson(Map<String, dynamic> json) =>
      _$PollOverviewFromJson(json);

  Map<String, dynamic> toJson() => toJsonPollOverview();

  Map<String, dynamic> toJsonPollOverview() => _$PollOverviewToJson(this);
}

@JsonSerializable()
class PollOverviewLocation extends PollOverview {
  double longitude, latitude, radius;

  PollOverviewLocation(id, title, startTime, endTime, participants,
      this.longitude, this.latitude, this.radius)
      : super(id, title, startTime, endTime, participants);

  factory PollOverviewLocation.fromDB(
      String pollId, Map<String, dynamic> json) {
    var map = Map<String, dynamic>.from(json);
    map['id'] = pollId;
    return PollOverviewLocation.fromJson(map);
  }

  factory PollOverviewLocation.fromJson(Map<String, dynamic> json) =>
      _$PollOverviewLocationFromJson(json);

  @override
  Map<String, dynamic> toJson() => toJsonPollOverviewLocation();

  Map<String, dynamic> toJsonPollOverviewLocation() =>
      _$PollOverviewLocationToJson(this);
}

@JsonSerializable()
class Poll extends PollOverviewLocation {
  //since we cant define a global fromJson(), we manually call it
  @JsonKey(ignore: true)
  late OrderedMapList<PollQuestion> questions = OrderedMapList.empty();

  Poll(id, title, startTime, endTime, participants, double longitude,
      double latitude, double radius)
      : super(id, title, startTime, endTime, participants, longitude, latitude,
            radius);

  factory Poll.fromDB(String pollId, Map<String, dynamic> json) {
    var map = Map<String, dynamic>.from(json);
    map['id'] = pollId;
    return Poll.fromJson(map);
  }

  factory Poll.questionlessFromDB(String pollId, Map<String, dynamic> json) {
    var map = Map<String, dynamic>.from(json);
    map['id'] = pollId;
    var el = _$PollFromJson(map);
    return el;
  }

  factory Poll.fromJson(Map<String, dynamic> json) {
    var el = _$PollFromJson(json);
    var questions = json['questions'];
    if (questions != null) {
      el.questions =
          OrderedMapList.from(questions, ({required String key, required Map<String, dynamic> value}) {
        //workaround for
        //TODO revert, use custom json converter
        return PollQuestion.from(key: key, map: value);
      });
    } else {}
    return el;
  }

  @override
  Map<String, dynamic> toJson() {
    var map = _$PollToJson(this);
    map.remove('id');
    map.addAll({
      'questions': questions.toJson(),
    });
    return map;
  }
}

abstract class PollLocation {
  Map<String, dynamic> toJson();
}

class CircleLocation extends PollLocation {
  double longitude, latitude, radius;

  CircleLocation({
    required this.longitude,
    required this.latitude,
    required this.radius,
  });

  factory CircleLocation.fromJson(Map<String, dynamic> map) {
    var longitude = map['longitude'];
    var latitude = map['latitude'];
    var radius = map['radius'];
    assert(longitude != null, 'longitude missing');
    assert(latitude != null, 'latitude missing');
    assert(radius != null, 'radius missing');
    return CircleLocation(
      longitude: longitude,
      latitude: latitude,
      radius: radius,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'longitude' : longitude,
    'latitude' : latitude,
    'radius' : radius,
  };

  @override
  String toString() => 'Circle->long:$longitude,lat:$latitude,radius:$radius';

}

