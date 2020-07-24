part of http_api;

class ApiResponse extends http.Response {
  /// Here you can assing your data that will be passed to the next link
  final Map<String, dynamic> linkData;

  /// Time when [ApiResponse] was created.
  final DateTime received;

  ApiResponse.fromHttp(http.BaseRequest request, http.Response response,
      Map<String, dynamic> linkData)
      : this.linkData = linkData ?? <String, dynamic>{},
        received = DateTime.now(),
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
