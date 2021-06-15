part of http_api;

/// Base class for implementing cachce managers.
///
/// Cache manaager is used by `BaseApi` class to cache responses.
///
/// BaseApi will not handle cache age,
/// it should be handled by CacheManager implementation.
abstract class CacheManager {
  /// Caches [response] under provided [key].
  FutureOr<void> write(CacheKey? key, Response? response);

  /// Reads cache saved under provided [key].
  FutureOr<Response>? read(CacheKey? key);

  /// Clears cache saved under provided [key].
  FutureOr<void> clear(CacheKey key);

  /// Clears all stored cache.
  FutureOr<void> clearAll();

  /// Disposes cache manager.
  ///
  /// This method all called together with [BaseApi] dispose method.
  void dispose() {}
}

/// Base class for implementing cache providers.
///
/// This class extends [BaseApi] class with
/// methods that enable cache handling.
mixin Cache<T extends CacheManager> on BaseApi {
  /// Creates instance of cache manager
  T createCacheManager();

  /// Whether [response] related to [request] should be saved to the cache.
  ///
  /// Default implementation:
  /// ```dart
  /// bool shouldUpdateCache(ApiRequest request, ApiResponse response) {
  ///  return request.key != null && response.ok;
  /// }
  /// ```
  bool shouldUpdateCache(Request request, Response? response) {
    return request.key != null && response!.ok;
  }

  CacheManager? _cache;

  /// Get cache manager.
  ///
  /// If cache manager wasn't already defined.
  CacheManager get cache => _cache ??= createCacheManager();

  @override
  Future<Response> send(Request request) async {
    final networkResponse = await super.send(request);

    /// Save cache when response is successful and request contains a key.
    if (shouldUpdateCache(request, networkResponse)) {
      /// Make sure that request contains CacheKey.
      _throwOnRequestWithoutCacheKey(request);
      await cache.write(request.key, networkResponse);
    }

    return networkResponse;
  }

  @override
  void dispose() {
    super.dispose();
    _cache!.dispose();
  }

  void _throwOnRequestWithoutCacheKey(Request request) {
    if (request.key == null) {
      throw ApiError(
        'CacheKey is required for requests with cache. '
        'Provide your ApiRequest instance with \'key\' argument.',
      );
    }
  }

  /// Retrieve response from the cache if available and then from the network.
  /// Returns `Stream<ApiResponse>` type.
  Stream<Response> cacheAndNetwork(Request request) async* {
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
  Future<Response> cacheIfAvailable(Request request) async {
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
