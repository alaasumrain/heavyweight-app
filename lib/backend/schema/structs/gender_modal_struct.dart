// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GenderModalStruct extends BaseStruct {
  GenderModalStruct({
    String? text,
    String? image,
  })  : _text = text,
        _image = image;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  set text(String? val) => _text = val;
  bool hasText() => _text != null;

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  set image(String? val) => _image = val;
  bool hasImage() => _image != null;

  static GenderModalStruct fromMap(Map<String, dynamic> data) =>
      GenderModalStruct(
        text: data['text'] as String?,
        image: data['image'] as String?,
      );

  static GenderModalStruct? maybeFromMap(dynamic data) => data is Map
      ? GenderModalStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'text': _text,
        'image': _image,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'text': serializeParam(
          _text,
          ParamType.String,
        ),
        'image': serializeParam(
          _image,
          ParamType.String,
        ),
      }.withoutNulls;

  static GenderModalStruct fromSerializableMap(Map<String, dynamic> data) =>
      GenderModalStruct(
        text: deserializeParam(
          data['text'],
          ParamType.String,
          false,
        ),
        image: deserializeParam(
          data['image'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'GenderModalStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GenderModalStruct &&
        text == other.text &&
        image == other.image;
  }

  @override
  int get hashCode => const ListEquality().hash([text, image]);
}

GenderModalStruct createGenderModalStruct({
  String? text,
  String? image,
}) =>
    GenderModalStruct(
      text: text,
      image: image,
    );
