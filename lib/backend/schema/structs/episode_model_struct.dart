// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class EpisodeModelStruct extends BaseStruct {
  EpisodeModelStruct({
    String? image,
    String? title,
    String? playText,
  })  : _image = image,
        _title = title,
        _playText = playText;

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

  // "playText" field.
  String? _playText;
  String get playText => _playText ?? '';
  set playText(String? val) => _playText = val;
  bool hasPlayText() => _playText != null;

  static EpisodeModelStruct fromMap(Map<String, dynamic> data) =>
      EpisodeModelStruct(
        image: data['image'] as String?,
        title: data['title'] as String?,
        playText: data['playText'] as String?,
      );

  static EpisodeModelStruct? maybeFromMap(dynamic data) => data is Map
      ? EpisodeModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'image': _image,
        'title': _title,
        'playText': _playText,
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
        'playText': serializeParam(
          _playText,
          ParamType.String,
        ),
      }.withoutNulls;

  static EpisodeModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      EpisodeModelStruct(
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
        playText: deserializeParam(
          data['playText'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'EpisodeModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is EpisodeModelStruct &&
        image == other.image &&
        title == other.title &&
        playText == other.playText;
  }

  @override
  int get hashCode => const ListEquality().hash([image, title, playText]);
}

EpisodeModelStruct createEpisodeModelStruct({
  String? image,
  String? title,
  String? playText,
}) =>
    EpisodeModelStruct(
      image: image,
      title: title,
      playText: playText,
    );
