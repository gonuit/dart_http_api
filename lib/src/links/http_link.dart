part of http_api;

class HttpLink extends ApiLink {
  @experimental
  Uri _apiUrl;
  @experimental
  Uri get apiUrl => _apiUrl;

  Uri getUrlForRequest(ApiRequest request) {
    ArgumentError.checkNotNull(request, 'request');
    if (!attached) {
      throw ApiError(
        'In order to create url for api, HttpLink '
        'must be attached to api class.',
      );
    }
    if (apiUrl == null) {
      throw ApiException("Property `apiUrl` is not available.");
    }

    final queryParameters = Map<String, dynamic>.from(apiUrl.queryParameters)
      ..addAll(request.queryParameters);

    return Uri(
      scheme: apiUrl.scheme,
      host: apiUrl.host,
      path: apiUrl.path + request.endpoint,
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      port: apiUrl.port,
    );
  }

  /// Builds http request from ApiRequest data
  FutureOr<http.BaseRequest> buildHttpRequest(ApiRequest request) {
    final url = getUrlForRequest(request);

    if (request.body is FormData) {
      return _buildFormDataRequest(url, request);
    } else {
      return _buildHttpRequest(url, request);
    }
  }

  /// Builds [FormDataRequest]
  Future<http.BaseRequest> _buildFormDataRequest(
    Uri url,
    ApiRequest<FormData> request,
  ) async {
    final formDataRequest = FormDataRequest(request.method.value, url)
      ..headers.addAll(request.headers);

    final formData = request.body;

    await formDataRequest.setEntries(formData.entries);

    return formDataRequest;
  }

  /// Builds [Request]
  http.BaseRequest _buildHttpRequest(
    Uri url,
    ApiRequest request,
  ) {
    final httpRequest = http.Request(request.method.value, url);

    if (request.headers != null) httpRequest.headers.addAll(request.headers);
    if (request.encoding != null) httpRequest.encoding = request.encoding;
    if (request.body != null) {
      if (request.body is String) {
        httpRequest.body = request.body;
      } else if (request.body is List) {
        httpRequest.bodyBytes = request.body.cast<int>();
      } else if (request.body is Map) {
        httpRequest.bodyFields = request.body.cast<String, String>();
      } else {
        throw ArgumentError('Invalid http request body "${request.body}".');
      }
    }
    return httpRequest;
  }

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
    final httpRequest = await buildHttpRequest(apiRequest);

    /// Sends a request
    final streamedResponse = await client.send(
      httpRequest,
    );

    /// Parses the response
    final httpResponse = await http.Response.fromStream(
      streamedResponse,
    );

    /// Returns the api response
    return ApiResponse(
      apiRequest,
      headers: httpResponse.headers,
      isRedirect: httpResponse.isRedirect,
      persistentConnection: httpResponse.persistentConnection,
      reasonPhrase: httpResponse.reasonPhrase,
      statusCode: httpResponse.statusCode,
      contentLength: httpResponse.contentLength,
      bodyBytes: httpResponse.bodyBytes,
    );
  }

  /// Closes client connection
  @override
  void dispose() {
    super.dispose();
    _client.close();
  }
}
