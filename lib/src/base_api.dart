part of http_api;

/// This class is a simple wrapper around `http` library
/// it's main target is to handle auth headers.
///
/// Override this class in order to
/// add your own request methods
abstract class BaseApi {
  @experimental
  final BaseApiCache _cache;

  final Uri _url;
  Uri get url => _url;
  final Map<String, String> defaultHeaders;
  final ApiLink _link;

  BaseApi({
    @required Uri url,
    ApiLink link,
    Map<String, String> defaultHeaders,
    @experimental BaseApiCache cache,
  })  : _cache = cache ?? ApiInMemoryCache(),
        assert(url != null, "url $runtimeType argument cannot be null"),
        _url = url,
        this.defaultHeaders = defaultHeaders ?? <String, String>{},
        _link = link._firstLink ?? link ?? HttpLink() {
    if (_link._firstWhere((apiLink) => (apiLink is HttpLink)) == null) {
      throw ApiException("ApiLinks chain should contain HttpLink");
    }

    if (_link._firstWhere((apiLink) => apiLink.closed) != null) {
      throw ApiException("Cannot assign closed ApiLinks chain to $runtimeType");
    }

    /// Close link chain
    _link._closeChain();
  }

  /// Get first link of provided type from current link chain.
  /// If ApiLink chain does not contain link of provided type, [null] will be returned.
  T getFirstLinkOfType<T>() =>
      _link?._firstWhere((ApiLink link) => link is T) as T;

  /// Make API request by triggering [ApiLink]s [next] methods
  Future<ApiResponse> send(ApiRequest request) async {
    /// Adds default headers to the request, but does not overrides existing ones
    request.headers.addAll(
      Map<String, String>.from(defaultHeaders)..addAll(request.headers),
    );

    /// Sets request api url
    request._apiUrl = url;

    return _link.next(request);
  }

  Stream<ApiResponse> sendWithCache(
    ApiRequest request, {
    @experimental bool updateCache = true,
  }) async* {
    assert(request.key != null, "request key cannot be null");

    final cacheFuture = loadCache(request.key);
    final networkFuture = send(request);

    if (cacheFuture != null) {
      final cache = await cacheFuture;
      if (cache != null) yield cache;
    }

    final response = await networkFuture;
    yield response;

    if (updateCache && request.key != null) {
      saveCache(request.key, response);
    }
  }

  @experimental
  FutureOr<ApiResponse> loadCache(Key key) {
    print("CACHE LOAD");
    return _cache.load(key);
  }

  @experimental
  @protected
  @visibleForTesting
  void saveCache(Key key, ApiResponse response) {
    print("CACHE SAVE");
    _cache.save(key, response);
  }

  /// closes http client
  void dispose() => _link._forEach((link) => link.dispose());
}
