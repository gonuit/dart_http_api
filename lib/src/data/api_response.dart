part of http_api;

class ApiResponse {
  final ApiRequest apiRequest;

  /// Id of current [ApiResponse].
  /// The same as related [ApiRequest] id.
  ObjectId get id => apiRequest.id;

  /// ApiRequest object creation timestamp.
  DateTime get createdAt => id.timestamp;

  /// Here you can assing your data that will be passed to the next link
  final Map<String, dynamic> linkData = <String, dynamic>{};

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
  String get body => _encodingForHeaders(headers).decode(bodyBytes);

  ApiResponse(
    this.apiRequest, {
    @required this.bodyBytes,
    @required this.statusCode,
    @required this.reasonPhrase,
    @required this.contentLength,
    @required this.headers,
    @required this.isRedirect,
    @required this.persistentConnection,
  }) : received = DateTime.now();

  Map<String, dynamic> toMap() => <String, dynamic>{
        "id": id.hexString,
        "apiRequest": apiRequest.toMap(),
        "bodyBytes": bodyBytes,
        "statusCode": statusCode,
        "reasonPhrase": reasonPhrase,
        "contentLength": contentLength,
        "headers": headers,
        "isRedirect": isRedirect,
        "persistentConnection": persistentConnection,
        "received": received.toIso8601String(),
      };

  String toJson() => jsonEncode(toMap());

  ApiResponse.fromJson(Map<String, dynamic> json)
      : apiRequest = ApiRequest.fromJson(json["apiRequest"]),
        bodyBytes = json["bodyBytes"],
        statusCode = json["statusCode"],
        reasonPhrase = json["reasonPhrase"],
        contentLength = json["contentLength"],
        headers = json["headers"],
        isRedirect = json["isRedirect"],
        persistentConnection = json["persistentConnection"],
        received = DateTime.parse(json["received"]);
}

// TODO: rewrite:

/// Returns the encoding to use for a response with the given headers.
///
/// Defaults to [latin1] if the headers don't specify a charset or if that
/// charset is unknown.
Encoding _encodingForHeaders(Map<String, String> headers) =>
    encodingForCharset(_contentTypeForHeaders(headers).parameters['charset']);

/// Returns the [MediaType] object for the given headers's content-type.
///
/// Defaults to `application/octet-stream`.
MediaType _contentTypeForHeaders(Map<String, String> headers) {
  var contentType = headers['content-type'];
  if (contentType != null) return MediaType.parse(contentType);
  return MediaType('application', 'octet-stream');
}

/// Returns the [Encoding] that corresponds to [charset].
///
/// Returns [fallback] if [charset] is null or if no [Encoding] was found that
/// corresponds to [charset].
Encoding encodingForCharset(String charset, [Encoding fallback = latin1]) {
  if (charset == null) return fallback;
  return Encoding.getByName(charset) ?? fallback;
}
