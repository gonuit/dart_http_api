part of http_api;

class HttpMethod {
  final String _value;

  /// Returns [String] that represents [HttpMethod]
  ///
  /// example:
  /// ```dart
  /// HttpMethod.post.value == "POST"
  /// ```
  String get value => _value;

  const HttpMethod._(this._value);

  static const post = HttpMethod._("POST");
  static const get = HttpMethod._("GET");
  static const delete = HttpMethod._("DELETE");
  static const put = HttpMethod._("PUT");
  static const patch = HttpMethod._("PATCH");
  static const head = HttpMethod._("HEAD");
}

/// Represents File that can be attached to [BaseApiRequest]
/// so can be sent to API
/// with [MultipartRequest]
abstract class FileField {
  final String field;
  final String fileName;
  final MediaType contentType;

  const FileField._({
    @required this.field,
    this.fileName,
    this.contentType,
  }) : assert(field != null, "field argument cannot be null");

  /// Convert FileField to multipart file
  Future<http.MultipartFile> toMultipartFile();

  factory FileField({
    File file,
    String field,
    String fileName,
    MediaType contentType,
  }) = _FileField;

  factory FileField.fromStream({
    @required String field,
    @required Stream<List<int>> stream,
    @required int length,
    String fileName,
    MediaType contentType,
  }) = _StreamFileField;

  Map<String, dynamic> toMap();

  @override
  String toString() => "$runtimeType(${toMap()})";
}

class _FileField extends FileField {
  final File file;

  _FileField({
    @required String field,
    @required this.file,
    String fileName,
    MediaType contentType,
  })  : assert(
          file != null,
          "file argument cannot be null",
        ),
        super._(
          field: field,
          fileName: fileName,
          contentType: contentType,
        );

  @override

  /// Convert FileField to multipart file
  Future<http.MultipartFile> toMultipartFile() async =>
      http.MultipartFile.fromPath(
        field,
        file.path,
        contentType: contentType,
        filename: fileName,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        "file": file,
        "field": field,
        "fileName": fileName,
        "contentType": contentType,
      };

  @override
  String toString() => "FileField(${toMap()})";
}

class _StreamFileField extends FileField {
  final Stream<List<int>> stream;
  final int length;

  _StreamFileField({
    @required String field,
    @required this.stream,
    @required this.length,
    MediaType contentType,
    String fileName,
  })  : assert(
          stream != null && length != null,
          "stream and length arguments cannot be null",
        ),
        super._(
          fileName: fileName,
          contentType: contentType,
          field: field,
        );

  Future<http.MultipartFile> toMultipartFile() async => http.MultipartFile(
        field,
        stream,
        length,
        filename: fileName,
        contentType: contentType,
      );

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        "field": field,
        "stream": stream,
        "length": length,
        "fileName": fileName,
        "contentType": contentType,
      };
}
