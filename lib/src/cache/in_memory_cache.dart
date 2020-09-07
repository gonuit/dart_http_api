part of http_api;

/// Simplest [CacheManager] implementation that stores ApiResponses in memory.
class InMemoryCache extends CacheManager {
  final _storage = <CacheKey, ApiResponse>{};

  @override
  ApiResponse read(CacheKey key) => _storage[key];

  @override
  void write(CacheKey key, ApiResponse response) => _storage[key] = response;

  @override
  ApiResponse clear(CacheKey key) => _storage.remove(key);

  @override
  void clearAll() => _storage.clear();
}
