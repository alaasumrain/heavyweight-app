// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GoalModelStruct extends BaseStruct {
  GoalModelStruct({
    String? image,
    String? title,
    String? checkBox,
  })  : _image = image,
        _title = title,
        _checkBox = checkBox;

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

  // "checkBox" field.
  String? _checkBox;
  String get checkBox => _checkBox ?? '';
  set checkBox(String? val) => _checkBox = val;
  bool hasCheckBox() => _checkBox != null;

  static GoalModelStruct fromMap(Map<String, dynamic> data) => GoalModelStruct(
        image: data['image'] as String?,
        title: data['title'] as String?,
        checkBox: data['checkBox'] as String?,
      );

  static GoalModelStruct? maybeFromMap(dynamic data) => data is Map
      ? GoalModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'image': _image,
        'title': _title,
        'checkBox': _checkBox,
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
        'checkBox': serializeParam(
          _checkBox,
          ParamType.String,
        ),
      }.withoutNulls;

  static GoalModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      GoalModelStruct(
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
        checkBox: deserializeParam(
          data['checkBox'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'GoalModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GoalModelStruct &&
        image == other.image &&
        title == other.title &&
        checkBox == other.checkBox;
  }

  @override
  int get hashCode => const ListEquality().hash([image, title, checkBox]);
}

GoalModelStruct createGoalModelStruct({
  String? image,
  String? title,
  String? checkBox,
}) =>
    GoalModelStruct(
      image: image,
      title: title,
      checkBox: checkBox,
    );
