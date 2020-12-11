part of http_api;

/// This class is a simple wrapper around `http` library
/// it's main target is to handle auth headers.
///
/// Override this class in order to
/// add your own request methods
abstract class BaseApi {
  final Uri url;
  final Map<String, String> defaultHeaders;
  final ApiLink _link;

  BaseApi(
    this.url, {
    ApiLink link,
    Map<String, String> defaultHeaders,
  })  : defaultHeaders = defaultHeaders ?? <String, String>{},
        _link = link?._firstLink ?? HttpLink() {
    ArgumentError.checkNotNull(url, 'url');

    if (_link._firstWhere((apiLink) => (apiLink is HttpLink)) == null) {
      throw ApiError("ApiLinks chain should contain HttpLink.");
    }

    if (_link._firstWhere((apiLink) => apiLink.attached) != null) {
      throw ApiError(
        "Cannot reattach already attached ApiLink to $runtimeType.",
      );
    }

    /// Close link chain
    _link._closeChain(url);
  }

  /// Get first link of provided type from current link chain.
  /// If ApiLink chain does not contain link of provided type,
  /// [null] will be returned.
  T getFirstLinkOfType<T extends ApiLink>() =>
      _link?._firstWhere((link) => link is T) as T;

  ApiLink getFirstLinkWhere(bool Function(ApiLink link) test) =>
      _link?._firstWhere(test);

  void forEachLink(void Function(ApiLink) callback) =>
      _link?._forEach(callback);

  /// {@template http_api.base_api.send}
  /// Make API request by triggering [ApiLink]s [next] methods
  /// {@endtemplate}
  Future<Response> send(Request request) async {
    /// Adds default headers to the request, but does not overrides
    /// existing ones
    request.headers.addAll(
      Map<String, String>.from(defaultHeaders)..addAll(request.headers),
    );

    return _link.next(request);
  }

  /// Send http **get** request.
  ///
  /// {@macro http_api.base_api.send}
  Future<Response> get(
    String endpoint, {
    Map<String, String> headers,
    Map<String, dynamic> queryParameters,
    Encoding encoding,
    DateTime createdAt,
    ObjectId id,
    CacheKey key,
  }) =>
      send(Request(
        endpoint: endpoint,
        headers: headers,
        queryParameters: queryParameters,
        encoding: encoding,
        createdAt: createdAt,
        id: id,
        key: key,
        method: HttpMethod.get,
      ));

  /// Send http **post** request.
  ///
  /// {@macro http_api.base_api.send}
  Future<Response> post(
    String endpoint, {
    Map<String, String> headers,
    Map<String, dynamic> queryParameters,
    dynamic body,
    Encoding encoding,
    DateTime createdAt,
    ObjectId id,
    CacheKey key,
  }) =>
      send(Request(
        endpoint: endpoint,
        headers: headers,
        queryParameters: queryParameters,
        body: body,
        encoding: encoding,
        createdAt: createdAt,
        id: id,
        key: key,
        method: HttpMethod.post,
      ));

  /// Send http **put** request.
  ///
  /// {@macro http_api.base_api.send}
  Future<Response> put(
    String endpoint, {
    Map<String, String> headers,
    Map<String, dynamic> queryParameters,
    dynamic body,
    Encoding encoding,
    DateTime createdAt,
    ObjectId id,
    CacheKey key,
  }) =>
      send(Request(
        endpoint: endpoint,
        headers: headers,
        queryParameters: queryParameters,
        body: body,
        encoding: encoding,
        createdAt: createdAt,
        id: id,
        key: key,
        method: HttpMethod.put,
      ));

  /// Send http **patch** request.
  ///
  /// {@macro http_api.base_api.send}
  Future<Response> patch(
    String endpoint, {
    Map<String, String> headers,
    Map<String, dynamic> queryParameters,
    dynamic body,
    Encoding encoding,
    DateTime createdAt,
    ObjectId id,
    CacheKey key,
  }) =>
      send(Request(
        endpoint: endpoint,
        headers: headers,
        queryParameters: queryParameters,
        body: body,
        encoding: encoding,
        createdAt: createdAt,
        id: id,
        key: key,
        method: HttpMethod.patch,
      ));

  /// Send http **delete** request.
  ///
  /// {@macro http_api.base_api.send}
  Future<Response> delete(
    String endpoint, {
    Map<String, String> headers,
    Map<String, dynamic> queryParameters,
    dynamic body,
    Encoding encoding,
    DateTime createdAt,
    ObjectId id,
    CacheKey key,
  }) =>
      send(Request(
        endpoint: endpoint,
        headers: headers,
        queryParameters: queryParameters,
        body: body,
        encoding: encoding,
        createdAt: createdAt,
        id: id,
        key: key,
        method: HttpMethod.delete,
      ));

  /// Send http **head** request.
  ///
  /// {@macro http_api.base_api.send}
  Future<Response> head(
    String endpoint, {
    Map<String, String> headers,
    Map<String, dynamic> queryParameters,
    Encoding encoding,
    DateTime createdAt,
    ObjectId id,
    CacheKey key,
  }) =>
      send(Request(
        endpoint: endpoint,
        headers: headers,
        queryParameters: queryParameters,
        encoding: encoding,
        createdAt: createdAt,
        id: id,
        key: key,
        method: HttpMethod.head,
      ));

  /// Disposes all links.
  void dispose() => _link._forEach((link) => link.dispose());
}
