part of http_api;

/// This class is a simple wrapper around `http` library
/// it's main target is to handle auth headers.
///
/// Override this class in order to
/// add your own methods / requests
///
/// Use call method to hand
abstract class ApiBase {
  final Uri _url;
  Uri get url => _url;
  final Map<String, String> _defaultHeaders;
  final ApiLink _link;

  ApiBase({
    @required Uri url,
    ApiLink link,
    Map<String, String> defaultHeaders,
  })  : assert(url != null, "url argument cannot be null"),
        _url = url,
        _defaultHeaders = defaultHeaders ?? const <String, String>{},
        _link = link._firstLink ?? link ?? HttpLink() {
    assert(
      _link._firstWhere((apiLink) => (apiLink is HttpLink)) != null,
      "ApiLinks chain should contain HttpLink",
    );

    /// Close link chain
    _link._closeChain();
  }

  /// Get first link of provided type from current link chain.
  /// If ApiLink chain does not contain link of provided type, [null] will be returned.
  T getFirstLinkOfType<T>() =>
      _link?._firstWhere((ApiLink link) => link is T) as T;

  /// Builds [Uri] object based on current Api url
  Uri getUrl(String endpoint, Map<String, String> queryParameters) => Uri(
        scheme: _url.scheme,
        host: _url.host,
        path: endpoint,
        queryParameters: queryParameters,
      );

  /// Returns default API headers with optional additional headers passed as an argument
  Map<String, String> getHeaders([Map<String, String> additionalHeaders]) =>
      Map<String, String>.from(_defaultHeaders)
        ..addAll(additionalHeaders ?? {});

  /// Make API request by triggering [ApiLink]s [next] methods
  Future<ApiResponse> callWithRequest(ApiRequest request) {
    return _link.next(request);
  }

  /// Call rest API by triggering the query lifecycle.
  /// Constructs [ApiRequest] object and invoke [ApiLink]s chain,
  /// then returns data received from it.
  Future<ApiResponse> call({
    @required String endpoint,
    dynamic body,
    Map<String, String> headers = const <String, String>{},
    Map<String, String> queryParameters,
    HttpMethod method = HttpMethod.get,
    List<FileField> fileFields,
    Encoding encoding,
    bool multipart,
  }) async {
    /// Builds url object
    Uri url = getUrl(endpoint, queryParameters);

    /// Builds request headers
    Map<String, String> requestHeaders = getHeaders(headers);

    final ApiRequest apiRequest = ApiRequest(
      url,
      method,
      headers: requestHeaders,
      body: body,
      fileFields: fileFields,
      encoding: encoding,
      multipart: multipart,
    );

    return callWithRequest(apiRequest);
  }

  /// closes http client
  void dispose() => _link._forEach((link) => link.dispose());
}

class RestApiBase extends ApiBase {}
