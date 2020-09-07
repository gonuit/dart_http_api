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
        _link = link._firstLink ?? HttpLink() {
    if (_link._firstWhere((apiLink) => (apiLink is HttpLink)) == null) {
      throw ApiError("ApiLinks chain should contain HttpLink");
    }

    if (_link._firstWhere((apiLink) => apiLink.closed) != null) {
      throw ApiError("Cannot assign closed ApiLinks chain to $runtimeType");
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

  /// Retrieve response from cache if available and then from network.
  @experimental
  Stream<ApiResponse> cacheAndNetwork(
    ApiRequest request, {
    @experimental bool updateCache = true,
  }) async* {
    if (request.key == null)
      throw ApiError('CacheKey is required for requests with cache.');

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
    if (updateCache) await saveCache(request.key, networkResponse);
  }

  /// Retrieve response from the cache if available or fallback to the network.
  @experimental
  Future<ApiResponse> cacheIfAvailable(
    ApiRequest request, {
    @experimental bool updateCache = true,
  }) async {
    if (request.key == null)
      throw ApiError('CacheKey is required for requests with cache.');

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

  /// Reads cache saved under provided [key].
  @experimental
  FutureOr<ApiResponse> readCache(CacheKey key) {
    assert((() {
      print("[CACHE] Read: $key");
      return true;
    })());

    return _cache.load(key);
  }

  /// Caches [response] under provided [key].
  @experimental
  FutureOr<void> saveCache(CacheKey key, ApiResponse response) {
    assert((() {
      print("[CACHE] Save: $key");
      return true;
    })());

    return _cache.save(key, response);
  }

  /// Disposes all links.
  void dispose() => _link._forEach((link) => link.dispose());
}
