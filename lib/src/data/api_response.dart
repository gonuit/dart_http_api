part of http_api;

class ApiResponse<T extends dynamic> {
  final ApiRequest<T> request;

  /// Id of current [ApiResponse].
  /// The same as related [ApiRequest] id.
  ObjectId get id => request.id;

  /// ApiRequest object creation timestamp.
  DateTime get createdAt => id.timestamp;

  /// Here you can assing your data that will be passed to the next link
  final Map<String, dynamic> linkData;

  /// Time when [ApiResponse] was created.
  final DateTime received;

  /// Represent reponse success
  ///
  /// [statusCode] is in the range from `200` to `299`, inclusive.
  bool get ok => statusCode >= 200 && statusCode <= 299;

  /// The HTTP status code for this response.
  final int statusCode;

  /// The reason phrase associated with the status code.
  final String reasonPhrase;

  /// The size of the response body, in bytes.
  ///
  /// If the size of the request is not known in advance, this is `null`.
  final int contentLength;

  final Map<String, String> headers;

  final bool isRedirect;

  /// Whether the server requested that a persistent connection be maintained.
  final bool persistentConnection;

  /// Represent redirect status.
  ///
  /// When [statusCode] equals `301`, `302`, `303`, `307`, or `308`.
  bool get redirect =>
      statusCode == 301 ||
      statusCode == 302 ||
      statusCode == 303 ||
      statusCode == 307 ||
      statusCode == 308;

  /// The bytes comprising the body of this response.
  final Uint8List bodyBytes;

  /// The body of the response as a string.
  ///
  /// This is converted from [bodyBytes] using the `charset` parameter of the
  /// `Content-Type` header field, if available. If it's unavailable or if the
  /// encoding name is unknown, [latin1] is used by default, as per
  /// [RFC 2616][].
  ///
  /// [RFC 2616]: http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html
  String get body => _getEncodingFromHeaders(headers).decode(bodyBytes);

  ApiResponse(
    this.request, {
    @required this.statusCode,
    this.bodyBytes,
    this.contentLength,
    this.reasonPhrase,
    Map<String, String> headers,
    this.isRedirect = false,
    this.persistentConnection = false,
  })  : received = DateTime.now(),
        linkData = request.linkData,
        headers = headers ?? <String, String>{};

  /// *************
  /// SERIALIZATION
  /// *************

  Map<String, dynamic> toJson() => <String, dynamic>{
        "id": id.hexString,
        "request": request.toJson(),
        "bodyBytes": bodyBytes,
        "statusCode": statusCode,
        "reasonPhrase": reasonPhrase,
        "contentLength": contentLength,
        "headers": headers,
        "isRedirect": isRedirect,
        "persistentConnection": persistentConnection,
        "received": received.toIso8601String(),
      };

  ApiResponse.fromJson(dynamic json)
      : request = ApiRequest.fromJson(json["request"]),
        bodyBytes =
            Uint8List.fromList(List.castFrom<dynamic, int>(json["bodyBytes"])),
        statusCode = json["statusCode"],
        reasonPhrase = json["reasonPhrase"],
        contentLength = json["contentLength"],
        headers =
            Map.castFrom<String, dynamic, String, String>(json["headers"]),
        isRedirect = json["isRedirect"],
        persistentConnection = json["persistentConnection"],
        received = DateTime.parse(json["received"]),
        linkData = <String, dynamic>{} {
    linkData.addAll(request.linkData);
  }

  String toString() => "$runtimeType(${toJson()})";
}
