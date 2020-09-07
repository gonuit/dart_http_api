part of http_api;

/// Base class for implementing cachce managers.
///
/// Cache manaager is used by `ApiClass` to cache responses.
@experimental
abstract class CacheManager {
  /// Caches [response] under provided [key].
  FutureOr<void> write(CacheKey key, ApiResponse response);

  /// Reads cache saved under provided [key].
  FutureOr<ApiResponse> read(CacheKey key);

  /// Clears cache saved under provided [key].
  FutureOr<void> clear(CacheKey key);

  /// Clears all stored cache.
  FutureOr<void> clearAll();
}

/// Base class for implementing cache providers.
///
/// This class extends [BaseApi] class with
/// methods that enable cache handling.
mixin Cache<T extends CacheManager> on BaseApi {
  /// Creates instance of cache manager
  T createCacheManager();

  CacheManager _cache;

  /// Get cache manager.
  ///
  /// If cache manager is wasn't already defined.
  CacheManager get cache => _cache ??= createCacheManager();

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    final networkResponse = await super.send(request);

    /// Save cache when response is successful and request contains a key.
    if (request.key != null && networkResponse.ok) {
      print("[CACHE] Save: ${request.key}");
      await cache.write(request.key, networkResponse);
    }

    return networkResponse;
  }

  void _throwOnRequestWithoutCacheKey(ApiRequest request) {
    if (request?.key == null) {
      throw ApiError(
        'CacheKey is required for requests with cache. '
        'Provide your ApiRequest instance with \'key\' argument.',
      );
    }
  }

  /// Retrieve response from cache if available and then from network.
  @experimental
  Stream<ApiResponse> cacheAndNetwork(
    ApiRequest request, {
    @experimental bool updateCache = true,
  }) async* {
    _throwOnRequestWithoutCacheKey(request);

    /// read cache
    final cacheFuture = cache.read(request.key);

    /// Start network fetch.
    /// Send method automatically updates cache.
    final networkFuture = send(request);

    /// wait for cache response
    final cachedResponse = await cacheFuture;

    /// return cache if available
    if (cachedResponse != null) yield cachedResponse;

    /// wait for network response
    final networkResponse = await networkFuture;

    /// yield network response
    yield networkResponse;
  }

  /// Retrieve response from the cache if available or fallback to the network.
  @experimental
  Future<ApiResponse> cacheIfAvailable(ApiRequest request) async {
    _throwOnRequestWithoutCacheKey(request);

    /// get cache
    final cachedResponse = await cache.read(request.key);

    if (cachedResponse != null) {
      return cachedResponse;
    } else {
      /// Get response from network.
      /// Send method automatically updates cache.
      final networkResponse = await send(request);

      return networkResponse;
    }
  }
}
