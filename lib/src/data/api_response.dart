part of http_api;

class ApiResponse extends http.Response {
  final ApiRequest apiRequest;

  /// Id of current [ApiResponse].
  /// The same as related [ApiRequest] id.
  ObjectId get id => apiRequest.id;

  /// ApiRequest object creation timestamp.
  final DateTime createdAt;

  /// Here you can assing your data that will be passed to the next link
  final Map<String, dynamic> linkData;

  /// Time when [ApiResponse] was created.

  /// Represent reponse success
  ///
  /// [statusCode] is in the range from `200` to `299`, inclusive.
  bool get ok => statusCode >= 200 && statusCode <= 299;

  /// Represent redirect status.
  ///
  /// When [statusCode] equals `301`, `302`, `303`, `307`, or `308`.
  bool get redirect =>
      statusCode == 301 ||
      statusCode == 302 ||
      statusCode == 303 ||
      statusCode == 307 ||
      statusCode == 308;

  ApiResponse.fromHttp(
      this.apiRequest, http.BaseRequest request, http.Response response)
      : linkData = apiRequest.linkData ?? <String, dynamic>{},
        createdAt = DateTime.now(),
        super(
          response.body,
          response.statusCode,
          request: request,
          headers: response.headers,
          isRedirect: response.isRedirect,
          persistentConnection: response.persistentConnection,
          reasonPhrase: response.reasonPhrase,
        );

  String toJson() {
    return jsonEncode(<String, dynamic>{
      "id": id.hexString,
      if (apiRequest.key != null) "key": apiRequest.key.value,
      "createdAt": createdAt.toIso8601String(),
      "redirect": redirect,
      "ok": ok,
      "headers": headers,
      "body": body,
      "persistentConnection": persistentConnection,
      "bodyBytes": bodyBytes,
      "reasonPhrase": reasonPhrase,
    });
  }
}
