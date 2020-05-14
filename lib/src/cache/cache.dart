part of http_api;

@experimental
abstract class BaseApiCache {
  void save(ValueKey key, ApiResponse response);
  Future<ApiResponse> load(ValueKey key);
}

class ApiInMemoryCache extends BaseApiCache {
  final _storage = <ValueKey, ApiResponse>{};

  @override
  Future<ApiResponse> load(ValueKey key) async => _storage[key];

  @override
  void save(ValueKey key, ApiResponse response) {
    _storage[key] = response;
  }
}
