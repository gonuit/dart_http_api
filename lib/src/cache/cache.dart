part of http_api;

@experimental
abstract class CacheManager {
  void save(ValueKey key, ApiResponse response);
  Future<ApiResponse> load(ValueKey key);
}
