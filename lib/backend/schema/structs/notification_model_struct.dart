// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class NotificationModelStruct extends BaseStruct {
  NotificationModelStruct({
    String? title,
    String? subTitle,
    String? time,
  })  : _title = title,
        _subTitle = subTitle,
        _time = time;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;
  bool hasTitle() => _title != null;

  // "subTitle" field.
  String? _subTitle;
  String get subTitle => _subTitle ?? '';
  set subTitle(String? val) => _subTitle = val;
  bool hasSubTitle() => _subTitle != null;

  // "time" field.
  String? _time;
  String get time => _time ?? '';
  set time(String? val) => _time = val;
  bool hasTime() => _time != null;

  static NotificationModelStruct fromMap(Map<String, dynamic> data) =>
      NotificationModelStruct(
        title: data['title'] as String?,
        subTitle: data['subTitle'] as String?,
        time: data['time'] as String?,
      );

  static NotificationModelStruct? maybeFromMap(dynamic data) => data is Map
      ? NotificationModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'title': _title,
        'subTitle': _subTitle,
        'time': _time,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'subTitle': serializeParam(
          _subTitle,
          ParamType.String,
        ),
        'time': serializeParam(
          _time,
          ParamType.String,
        ),
      }.withoutNulls;

  static NotificationModelStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      NotificationModelStruct(
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        subTitle: deserializeParam(
          data['subTitle'],
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
  String toString() => 'NotificationModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is NotificationModelStruct &&
        title == other.title &&
        subTitle == other.subTitle &&
        time == other.time;
  }

  @override
  int get hashCode => const ListEquality().hash([title, subTitle, time]);
}

NotificationModelStruct createNotificationModelStruct({
  String? title,
  String? subTitle,
  String? time,
}) =>
    NotificationModelStruct(
      title: title,
      subTitle: subTitle,
      time: time,
    );
