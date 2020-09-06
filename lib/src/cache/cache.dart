part of http_api;

@experimental
abstract class CacheManager {
  void save(CacheKey key, ApiResponse response);
  Future<ApiResponse> load(CacheKey key);
}
