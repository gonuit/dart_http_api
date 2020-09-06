part of http_api;

class InMemoryCache extends CacheManager {
  final _storage = <CacheKey, ApiResponse>{};

  @override
  Future<ApiResponse> load(CacheKey key) async => _storage[key];

  @override
  void save(CacheKey key, ApiResponse response) {
    _storage[key] = response;
  }
}
