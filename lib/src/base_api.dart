part of http_api;

/// This class is a simple wrapper around `http` library
/// it's main target is to handle auth headers.
///
/// Override this class in order to
/// add your own request methods
abstract class BaseApi {
  final Uri _url;
  Uri get url => _url;
  final Map<String, String> defaultHeaders;
  final ApiLink _link;

  BaseApi(
    Uri url, {
    ApiLink link,
    Map<String, String> defaultHeaders,

    /// Cache menager that will be used for cache storing.
    @experimental CacheManager cache,
  })  : assert(url != null, "url $runtimeType argument cannot be null"),
        _url = url,
        defaultHeaders = defaultHeaders ?? <String, String>{},
        _link = link._firstLink ?? HttpLink() {
    if (_link._firstWhere((apiLink) => (apiLink is HttpLink)) == null) {
      throw ApiError("ApiLinks chain should contain HttpLink");
    }

    if (_link._firstWhere((apiLink) => apiLink.closed) != null) {
      throw ApiError("Cannot assign closed ApiLinks chain to $runtimeType");
    }

    /// Close link chain
    _link._closeChain();
  }

  /// Get first link of provided type from current link chain.
  /// If ApiLink chain does not contain link of provided type,
  /// [null] will be returned.
  T getFirstLinkOfType<T>() => _link?._firstWhere((link) => link is T) as T;

  /// Make API request by triggering [ApiLink]s [next] methods
  Future<ApiResponse> send(ApiRequest request) async {
    /// Adds default headers to the request, but does not overrides
    /// existing ones
    request.headers.addAll(
      Map<String, String>.from(defaultHeaders)..addAll(request.headers),
    );

    /// Sets request api url
    request._apiUrl = url;

    return _link.next(request);
  }

  /// Disposes all links.
  void dispose() => _link._forEach((link) => link.dispose());
}
