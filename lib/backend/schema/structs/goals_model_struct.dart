// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GoalsModelStruct extends BaseStruct {
  GoalsModelStruct({
    String? unselectImage,
    String? selectImage,
    String? checkSelect,
    String? checkUnSelect,
    String? text,
  })  : _unselectImage = unselectImage,
        _selectImage = selectImage,
        _checkSelect = checkSelect,
        _checkUnSelect = checkUnSelect,
        _text = text;

  // "unselectImage" field.
  String? _unselectImage;
  String get unselectImage => _unselectImage ?? '';
  set unselectImage(String? val) => _unselectImage = val;
  bool hasUnselectImage() => _unselectImage != null;

  // "selectImage" field.
  String? _selectImage;
  String get selectImage => _selectImage ?? '';
  set selectImage(String? val) => _selectImage = val;
  bool hasSelectImage() => _selectImage != null;

  // "checkSelect" field.
  String? _checkSelect;
  String get checkSelect => _checkSelect ?? '';
  set checkSelect(String? val) => _checkSelect = val;
  bool hasCheckSelect() => _checkSelect != null;

  // "checkUnSelect" field.
  String? _checkUnSelect;
  String get checkUnSelect => _checkUnSelect ?? '';
  set checkUnSelect(String? val) => _checkUnSelect = val;
  bool hasCheckUnSelect() => _checkUnSelect != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  set text(String? val) => _text = val;
  bool hasText() => _text != null;

  static GoalsModelStruct fromMap(Map<String, dynamic> data) =>
      GoalsModelStruct(
        unselectImage: data['unselectImage'] as String?,
        selectImage: data['selectImage'] as String?,
        checkSelect: data['checkSelect'] as String?,
        checkUnSelect: data['checkUnSelect'] as String?,
        text: data['text'] as String?,
      );

  static GoalsModelStruct? maybeFromMap(dynamic data) => data is Map
      ? GoalsModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'unselectImage': _unselectImage,
        'selectImage': _selectImage,
        'checkSelect': _checkSelect,
        'checkUnSelect': _checkUnSelect,
        'text': _text,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'unselectImage': serializeParam(
          _unselectImage,
          ParamType.String,
        ),
        'selectImage': serializeParam(
          _selectImage,
          ParamType.String,
        ),
        'checkSelect': serializeParam(
          _checkSelect,
          ParamType.String,
        ),
        'checkUnSelect': serializeParam(
          _checkUnSelect,
          ParamType.String,
        ),
        'text': serializeParam(
          _text,
          ParamType.String,
        ),
      }.withoutNulls;

  static GoalsModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      GoalsModelStruct(
        unselectImage: deserializeParam(
          data['unselectImage'],
          ParamType.String,
          false,
        ),
        selectImage: deserializeParam(
          data['selectImage'],
          ParamType.String,
          false,
        ),
        checkSelect: deserializeParam(
          data['checkSelect'],
          ParamType.String,
          false,
        ),
        checkUnSelect: deserializeParam(
          data['checkUnSelect'],
          ParamType.String,
          false,
        ),
        text: deserializeParam(
          data['text'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'GoalsModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GoalsModelStruct &&
        unselectImage == other.unselectImage &&
        selectImage == other.selectImage &&
        checkSelect == other.checkSelect &&
        checkUnSelect == other.checkUnSelect &&
        text == other.text;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([unselectImage, selectImage, checkSelect, checkUnSelect, text]);
}

GoalsModelStruct createGoalsModelStruct({
  String? unselectImage,
  String? selectImage,
  String? checkSelect,
  String? checkUnSelect,
  String? text,
}) =>
    GoalsModelStruct(
      unselectImage: unselectImage,
      selectImage: selectImage,
      checkSelect: checkSelect,
      checkUnSelect: checkUnSelect,
      text: text,
    );
