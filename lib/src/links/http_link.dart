part of http_api;

class HttpLink with ApiLink {
  /// Client is needed for persistent connection
  final http.Client _client;

  /// Http client used by this link
  http.Client get client => _client;

  /// ApiLink that closes link chain. Responsible for HTTP calls.
  HttpLink([http.Client client]) : _client = client ?? http.Client();

  @override
  @protected
  Future<ApiResponse> next(ApiRequest apiRequest) async {
    /// Builds a http request
    final httpRequest = await apiRequest.buildRequest();

    /// Sends a request
    http.StreamedResponse streamedResponse = await client.send(
      httpRequest,
    );

    /// Parses the response
    http.Response httpResponse = await http.Response.fromStream(
      streamedResponse,
    );

    /// Returns the api response
    return ApiResponse.fromHttp(
      httpRequest,
      httpResponse,
      apiRequest.linkData,
    );
  }

  /// Closes client connection
  @override
  void dispose() {
    super.dispose();
    _client.close();
  }
}
