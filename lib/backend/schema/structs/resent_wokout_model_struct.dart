// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ResentWokoutModelStruct extends BaseStruct {
  ResentWokoutModelStruct({
    String? title,
    String? subText,
    String? time,
  })  : _title = title,
        _subText = subText,
        _time = time;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;
  bool hasTitle() => _title != null;

  // "subText" field.
  String? _subText;
  String get subText => _subText ?? '';
  set subText(String? val) => _subText = val;
  bool hasSubText() => _subText != null;

  // "time" field.
  String? _time;
  String get time => _time ?? '';
  set time(String? val) => _time = val;
  bool hasTime() => _time != null;

  static ResentWokoutModelStruct fromMap(Map<String, dynamic> data) =>
      ResentWokoutModelStruct(
        title: data['title'] as String?,
        subText: data['subText'] as String?,
        time: data['time'] as String?,
      );

  static ResentWokoutModelStruct? maybeFromMap(dynamic data) => data is Map
      ? ResentWokoutModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'title': _title,
        'subText': _subText,
        'time': _time,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'subText': serializeParam(
          _subText,
          ParamType.String,
        ),
        'time': serializeParam(
          _time,
          ParamType.String,
        ),
      }.withoutNulls;

  static ResentWokoutModelStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ResentWokoutModelStruct(
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        subText: deserializeParam(
          data['subText'],
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
  String toString() => 'ResentWokoutModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ResentWokoutModelStruct &&
        title == other.title &&
        subText == other.subText &&
        time == other.time;
  }

  @override
  int get hashCode => const ListEquality().hash([title, subText, time]);
}

ResentWokoutModelStruct createResentWokoutModelStruct({
  String? title,
  String? subText,
  String? time,
}) =>
    ResentWokoutModelStruct(
      title: title,
      subText: subText,
      time: time,
    );
