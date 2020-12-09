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

  factory HttpMethod.fromString(String method) {
    switch (method) {
      case "POST":
        return post;
      case "GET":
        return get;
      case "DELETE":
        return delete;
      case "PUT":
        return put;
      case "PATCH":
        return patch;
      case "HEAD":
        return head;
      default:
        return null;
    }
  }
}

enum RequestType { basic, formData }

extension on RequestType {
  String get value {
    switch (this) {
      case RequestType.basic:
        return "basic";
      case RequestType.formData:
        return "formData";
      default:
        throw UnimplementedError();
    }
  }
}

/// Represents File that can be attached to [BaseApiRequest]
/// so can be sent to API
/// with [FormDataRequest]
abstract class FileField {
  final String fileName;
  final MediaType contentType;

  const FileField._({
    this.fileName,
    this.contentType,
  });

  /// Convert FileField to multipart file.
  Future<http.MultipartFile> toMultipartFile(final String field);

  factory FileField({
    File file,
    String fileName,
    MediaType contentType,
  }) = _FileField;

  /// Creates FileField from byte stream.
  factory FileField.fromStream({
    @required Stream<List<int>> stream,
    @required int length,
    String fileName,
    MediaType contentType,
  }) = _StreamFileField;

  /// This method is most commonly used to convert
  /// [FileField] to JSON in order to prepare it for caching.
  ///
  /// This method should not return a file, only data
  /// describing the file.
  Map<String, dynamic> toJson() => <String, dynamic>{
        "fileName": fileName,
        "contentType": contentType,
      };

  /// Construct FileField that only represents file without including it.
  /// This constructor can be used for caching.
  factory FileField.fromJson(dynamic json) => _FileDataField(
        field: json["field"],
        fileName: json["fileName"],
        contentType: json["contentType"],
      );

  @override
  String toString() => "$runtimeType(${toJson()})";
}

class _FileDataField extends FileField {
  _FileDataField({
    @required String field,
    String fileName,
    MediaType contentType,
  }) : super._(
          fileName: fileName,
          contentType: contentType,
        );

  @override
  Future<http.MultipartFile> toMultipartFile(final String field) async {
    throw ApiError(
      '$runtimeType cannot be converted to multipart file. '
      'This problem may occur when you try to send a FileField '
      'created by calling the fromJson constructor.',
    );
  }

  @override
  String toString() => "$runtimeType(${toJson()})";
}

class _FileField extends FileField {
  final File file;

  _FileField({
    @required this.file,
    String fileName,
    MediaType contentType,
  })  : assert(
          file != null,
          "file argument cannot be null",
        ),
        super._(
          fileName: fileName,
          contentType: contentType,
        );

  @override

  /// Convert FileField to multipart file
  Future<http.MultipartFile> toMultipartFile(final String field) async =>
      http.MultipartFile.fromPath(
        field,
        file.path,
        contentType: contentType,
        filename: fileName,
      );
}

class _StreamFileField extends FileField {
  final Stream<List<int>> stream;
  final int length;

  _StreamFileField({
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
        );

  Future<http.MultipartFile> toMultipartFile(final String field) async =>
      http.MultipartFile(
        field,
        stream,
        length,
        filename: fileName,
        contentType: contentType,
      );
}
