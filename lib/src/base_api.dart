part of http_api;

/// This class is a simple wrapper around `http` library
/// it's main target is to handle auth headers.
///
/// Override this class in order to
/// add your own request methods
abstract class BaseApi {
  @experimental
  final CacheManager _cache;

  final Uri _url;
  Uri get url => _url;
  final Map<String, String> defaultHeaders;
  final ApiLink _link;

  BaseApi({
    @required Uri url,
    ApiLink link,
    Map<String, String> defaultHeaders,

    /// Cache menager that will be used for cache storing.
    @experimental CacheManager cache,
  })  : _cache = cache ?? InMemoryCache(),
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

  /// Retrive response from cache if available and then from network.
  @experimental
  Stream<ApiResponse> cacheAndNetwork(
    ApiRequest request, {
    @experimental bool updateCache = true,
  }) async* {
    if (request.key == null) throw ApiException('Request key cannot be null');

    /// read cache
    final cacheFuture = readCache(request.key);

    /// start network fetch
    final networkFuture = send(request);

    /// wait for cache response
    final cachedResponse = await cacheFuture;

    /// return cache if available
    if (cachedResponse != null) yield cachedResponse;

    /// wait for network response
    final networkResponse = await networkFuture;

    /// yield network response
    yield networkResponse;

    /// save cache when response is successful
    if (updateCache) saveCache(request.key, networkResponse);
  }

  /// Retrive response from cache if available and then from network.
  @experimental
  Future<ApiResponse> cacheIfAvailable(
    ApiRequest request, {
    @experimental bool updateCache = true,
  }) async {
    if (request.key == null) throw ApiException('Request key cannot be null');

    /// get cache
    final cachedResponse = await readCache(request.key);

    if (cachedResponse != null) {
      return cachedResponse;
    } else {
      /// get response from network
      final networkResponse = await send(request);

      /// save cache when response is successful
      if (updateCache && networkResponse.ok)
        saveCache(request.key, networkResponse);

      return networkResponse;
    }
  }

  @experimental
  FutureOr<ApiResponse> readCache(Key key) {
    print("CACHE READED; KEY: $key");
    return _cache.load(key);
  }

  @experimental
  void saveCache(Key key, ApiResponse response) {
    print("CACHE SAVED; KEY: $key");
    _cache.save(key, response);
  }

  /// closes http client
  void dispose() => _link._forEach((link) => link.dispose());
}
