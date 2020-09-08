part of http_api;

/// Simplest [CacheManager] implementation that stores ApiResponses in memory.
/// The cache will be cleared, along with api 'dispose' method invocation.
class InMemoryCache extends CacheManager {
  final _storage = <CacheKey, ApiResponse>{};

  @override
  ApiResponse read(CacheKey key) => _storage[key];

  @override
  void write(CacheKey key, ApiResponse response) => _storage[key] = response;

  @override
  void clear(CacheKey key) => _storage.remove(key);

  @override
  void clearAll() => _storage.clear();

  @override
  void dispose() {
    _storage.clear();
    super.dispose();
  }
}
