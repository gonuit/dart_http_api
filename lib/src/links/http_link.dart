part of http_api;

class HttpLink with ApiLink {
  /// Client is needed for persistent connection
  final http.Client _client;

  /// Http client used by this link
  http.Client get client => _client;

  /// ApiLink that closes link chain. Responsible for HTTP calls
  HttpLink([http.Client client]) : _client = client ?? http.Client();

  @override
  @protected
  Future<ApiResponse> next(ApiRequest apiRequest) async {
    return await apiRequest.send(client);
  }

  @override
  void dispose() {
    super.dispose();
    _client.close();
  }
}
