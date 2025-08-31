// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TodayWorkoutPlanPageStruct extends BaseStruct {
  TodayWorkoutPlanPageStruct({
    String? image,
    String? title,
    String? rating,
    String? time,
  })  : _image = image,
        _title = title,
        _rating = rating,
        _time = time;

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  set image(String? val) => _image = val;
  bool hasImage() => _image != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;
  bool hasTitle() => _title != null;

  // "rating" field.
  String? _rating;
  String get rating => _rating ?? '';
  set rating(String? val) => _rating = val;
  bool hasRating() => _rating != null;

  // "time" field.
  String? _time;
  String get time => _time ?? '';
  set time(String? val) => _time = val;
  bool hasTime() => _time != null;

  static TodayWorkoutPlanPageStruct fromMap(Map<String, dynamic> data) =>
      TodayWorkoutPlanPageStruct(
        image: data['image'] as String?,
        title: data['title'] as String?,
        rating: data['rating'] as String?,
        time: data['time'] as String?,
      );

  static TodayWorkoutPlanPageStruct? maybeFromMap(dynamic data) => data is Map
      ? TodayWorkoutPlanPageStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'image': _image,
        'title': _title,
        'rating': _rating,
        'time': _time,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'image': serializeParam(
          _image,
          ParamType.String,
        ),
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'rating': serializeParam(
          _rating,
          ParamType.String,
        ),
        'time': serializeParam(
          _time,
          ParamType.String,
        ),
      }.withoutNulls;

  static TodayWorkoutPlanPageStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      TodayWorkoutPlanPageStruct(
        image: deserializeParam(
          data['image'],
          ParamType.String,
          false,
        ),
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        rating: deserializeParam(
          data['rating'],
          ParamType.String,
          false,
        ),
        time: deserializeParam(
          data['time'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'TodayWorkoutPlanPageStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is TodayWorkoutPlanPageStruct &&
        image == other.image &&
        title == other.title &&
        rating == other.rating &&
        time == other.time;
  }

  @override
  int get hashCode => const ListEquality().hash([image, title, rating, time]);
}

TodayWorkoutPlanPageStruct createTodayWorkoutPlanPageStruct({
  String? image,
  String? title,
  String? rating,
  String? time,
}) =>
    TodayWorkoutPlanPageStruct(
      image: image,
      title: title,
      rating: rating,
      time: time,
    );
