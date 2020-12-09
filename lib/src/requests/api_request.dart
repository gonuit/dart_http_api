part of http_api;

// ignore_for_file: unnecessary_getters_setters

class ApiRequest<T extends dynamic> {
  final requestType = RequestType.basic;

  /// The id of current request.
  ///
  /// If you supply it by argument, try to make it unique
  /// across all requests (including those stored in the cache).
  ///
  /// If not provided through arguments, will be Generated automatically.
  final ObjectId id;

  /// Request creation timestamp.
  ///
  /// By default set to now.
  final DateTime createdAt;

  /// Identifies (groups) requests.
  ///
  /// Used for caching purposes - as cache key.
  CacheKey key;
  String endpoint;
  HttpMethod method;
  Encoding encoding;
  T body;

  /// Here you can assign your data that will be passed to the next link
  final Map<String, dynamic> linkData = {};
  final Map<String, String> headers = {};
  final Map<String, dynamic> queryParameters = {};

  ApiRequest({
    @required this.endpoint,
    this.method = HttpMethod.get,
    Map<String, String> headers,
    Map<String, dynamic> queryParameters,
    this.body,
    this.encoding,
    DateTime createdAt,
    ObjectId id,
    this.key,
  })  : createdAt = createdAt ?? DateTime.now(),
        id = id ?? ObjectId(),
        assert(
          endpoint != null && method != null,
          "endpoint and method arguments cannot be null",
        ) {
    if (headers != null) this.headers.addAll(headers);
    if (queryParameters != null) this.queryParameters.addAll(queryParameters);
  }

  /// *************
  /// SERIALIZATION
  /// *************

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id.hexString,
      "key": key.value,
      "endpoint": endpoint,
      "body": body,
      "encoding": encoding?.name,
      "headers": headers,
      "method": method.value,
      "queryParameters": queryParameters,
      "createdAt": createdAt.toIso8601String(),
      "_request_type": requestType.value,
    };
  }

  ApiRequest.fromJson(dynamic json)
      : id = ObjectId.fromHexString(json["id"]),
        key = CacheKey(json["key"]),
        endpoint = json["endpoint"],
        body = json["body"],
        encoding = Encoding.getByName(json["encoding"]),
        method = HttpMethod.fromString(json["method"]),
        createdAt = DateTime.parse(json["createdAt"]) {
    headers.addAll(
      Map.castFrom<String, dynamic, String, String>(json["headers"]),
    );
    queryParameters.addAll(json["queryParameters"]);
  }

  String toString() => "$runtimeType(${toJson()})";
}
