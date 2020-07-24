part of http_api;

class InMemoryCache extends CacheManager {
  final _storage = <ValueKey, ApiResponse>{};

  @override
  Future<ApiResponse> load(ValueKey key) async => _storage[key];

  @override
  void save(ValueKey key, ApiResponse response) {
    _storage[key] = response;
  }
}
