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

/// Represents File that can be attached to [BaseApiRequest] so can be sent to API
/// with [MultipartRequest]
class FileField {
  final File file;
  final String field;
  final String fileName;
  final MediaType contentType;

  const FileField({
    @required this.field,
    @required this.file,
    this.fileName,
    this.contentType,
  }) : assert(
          file != null && field != null,
          "file and field arguments cannot be null",
        );

  /// Convert FileField to multipart file
  Future<http.MultipartFile> toMultipartFile() => http.MultipartFile.fromPath(
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
