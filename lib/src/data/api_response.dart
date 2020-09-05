part of http_api;

class ApiResponse extends http.Response {
  final ObjectId _id;

  /// Id of current ApiRequest
  ObjectId get id => _id;

  /// Here you can assing your data that will be passed to the next link
  final Map<String, dynamic> linkData;

  /// Time when [ApiResponse] was created.
  final DateTime received;

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
      ApiRequest apiRequest, http.BaseRequest request, http.Response response)
      : linkData = apiRequest.linkData ?? <String, dynamic>{},
        received = DateTime.now(),
        _id = apiRequest.id,
        super(
          response.body,
          response.statusCode,
          request: request,
          headers: response.headers,
          isRedirect: response.isRedirect,
          persistentConnection: response.persistentConnection,
          reasonPhrase: response.reasonPhrase,
        );
}
