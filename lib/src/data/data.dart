part of http_api;

mixin Serializable {
  dynamic toJson();
}

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
        throw UnsupportedError('Method \'$method\' is not supported.');
    }
  }
}

class DataType {
  final String _value;

  /// Returns [String] that represents [DataType]
  ///
  /// example:
  /// ```dart
  /// DataType.formData.value == "FORM_DATA"
  /// ```
  String get value => _value;

  const DataType._(this._value);

  static const formData = DataType._("FORM_DATA");

  factory DataType.fromString(String dataType) {
    switch (dataType) {
      case "FORM_DATA":
        return formData;
      default:
        throw UnsupportedError('DataType \'$dataType\' is not supported.');
    }
  }
}

/// Represents File that can be attached to [BaseApiRequest]
/// so can be sent to API
/// with [FormDataRequest]
abstract class FileField {
  final String? filename;
  final MediaType? contentType;

  const FileField._({
    this.filename,
    this.contentType,
  });

  /// Convert FileField to multipart file.
  Future<http.MultipartFile?> toMultipartFile(final String field);

  factory FileField({
    required XFile file,
    String? filename,
    MediaType? contentType,
  }) = FileFieldWithFile;

  /// Creates FileField from byte stream.
  factory FileField.fromStream({
    required Stream<List<int>> stream,
    required int length,
    String? filename,
    MediaType? contentType,
  }) = FileFieldWithStream;

  /// This method is most commonly used to convert
  /// [FileField] to JSON in order to prepare it for caching.
  ///
  /// This method should not return a file, only data
  /// describing the file.
  Map<String, dynamic>? toJson() => <String, dynamic>{
        "filename": filename,
        "contentType": contentType,
      };

  /// Construct FileField that only represents file without including it.
  /// This constructor can be used for caching.
  factory FileField.fromJson(dynamic json) => _FileDataField(
        field: json["field"],
        filename: json["filename"],
        contentType: json["contentType"],
      );

  @override
  String toString() => "$runtimeType(${toJson()})";
}

class _FileDataField extends FileField {
  _FileDataField({
    required String? field,
    String? filename,
    MediaType? contentType,
  }) : super._(
          filename: filename,
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

class FileFieldWithFile extends FileField {
  final XFile file;

  FileFieldWithFile({
    required this.file,
    String? filename,
    MediaType? contentType,
  }) : super._(
          filename: filename,
          contentType: contentType,
        );

  @override

  /// Convert FileField to multipart file
  Future<http.MultipartFile> toMultipartFile(final String field) async =>
      http.MultipartFile.fromPath(
        field,
        file.path,
        contentType: contentType,
        filename: filename,
      );
}

class FileFieldWithStream extends FileField {
  final Stream<List<int>> stream;
  final int length;

  FileFieldWithStream({
    required this.stream,
    required this.length,
    MediaType? contentType,
    String? filename,
  }) : super._(
          filename: filename,
          contentType: contentType,
        );

  Future<http.MultipartFile> toMultipartFile(final String field) async =>
      http.MultipartFile(
        field,
        stream,
        length,
        filename: filename,
        contentType: contentType,
      );
}
