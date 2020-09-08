part of http_api;

// ignore_for_file: unnecessary_getters_setters

class ApiRequest {
  CacheKey _key;

  /// Identifies (groups) requests.
  ///
  /// Used for caching purposes - as cache key.
  CacheKey get key => _key;
  set key(CacheKey value) => _key = value;

  /// The id of current request.
  ///
  /// If you supply it by argument, try to make it unique
  /// across all requests (including those stored in the cache).
  ///
  /// If not provided through arguments, will be Generated automatically.
  final ObjectId id;

  final _createdAt = DateTime.now();

  /// ApiRequest object creation timestamp.
  DateTime get createdAt => _createdAt;

  String endpoint;
  HttpMethod method;
  Encoding encoding;
  bool multipart;
  dynamic body;

  /// Here you can assign your data that will be passed to the next link
  final Map<String, dynamic> linkData = {};
  final List<FileField> fileFields = [];
  final Map<String, String> headers = {};
  final Map<String, dynamic> queryParameters = {};

  /// If [BaseApiRequest] contains files or [multipart] property is set to true
  /// [isMultipart] equals true
  bool get isMultipart => multipart == true || fileFields.isNotEmpty;

  ApiRequest({
    @required this.endpoint,
    this.method = HttpMethod.get,
    Map<String, String> headers,
    List<FileField> fileFields,
    Map<String, dynamic> queryParameters,
    this.body,
    this.encoding,
    this.multipart,
    ObjectId id,
    CacheKey key,
  })  : _key = key,
        id = id ?? ObjectId(),
        assert(
          endpoint != null && method != null,
          "endpoint and method arguments cannot be null",
        ) {
    if (fileFields != null) this.fileFields.addAll(fileFields);
    if (headers != null) this.headers.addAll(headers);
    if (queryParameters != null) this.queryParameters.addAll(queryParameters);
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        "endpoint": endpoint,
        "body": body,
        "encoding": encoding,
        "fileFields": fileFields,
        "headers": headers,
        "linkData": linkData,
        "method": method.value,
        "multipart": multipart,
      };

  String toString() => "$runtimeType(${toMap()})";
}
