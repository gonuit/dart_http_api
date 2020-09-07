part of http_api;

@experimental
abstract class CacheManager {
  FutureOr<void> save(CacheKey key, ApiResponse response);
  FutureOr<ApiResponse> load(CacheKey key);
}
