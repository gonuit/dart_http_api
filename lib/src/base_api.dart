part of http_api;

/// This class is a simple wrapper around `http` library
/// it's main target is to handle auth headers.
///
/// Override this class in order to
/// add your own request methods
abstract class BaseApi {
  final Uri url;
  final Map<String, String> defaultHeaders;
  final ApiLink _link;

  BaseApi(
    this.url, {
    ApiLink link,
    Map<String, String> defaultHeaders,
  })  : defaultHeaders = defaultHeaders ?? <String, String>{},
        _link = link?._firstLink ?? HttpLink() {
    ArgumentError.checkNotNull(url, 'url');

    if (_link._firstWhere((apiLink) => (apiLink is HttpLink)) == null) {
      throw ApiError("ApiLinks chain should contain HttpLink.");
    }

    if (_link._firstWhere((apiLink) => apiLink.attached) != null) {
      throw ApiError(
        "Cannot reattach already attached ApiLink to $runtimeType.",
      );
    }

    /// Close link chain
    _link._closeChain(url);
  }

  /// Get first link of provided type from current link chain.
  /// If ApiLink chain does not contain link of provided type,
  /// [null] will be returned.
  T getFirstLinkOfType<T extends ApiLink>() =>
      _link?._firstWhere((link) => link is T) as T;

  ApiLink getFirstLinkWhere(bool Function(ApiLink link) test) =>
      _link?._firstWhere(test);

  void forEachLink(void Function(ApiLink) callback) =>
      _link?._forEach(callback);

  /// Make API request by triggering [ApiLink]s [next] methods
  Future<ApiResponse> send(ApiRequest request) async {
    /// Adds default headers to the request, but does not overrides
    /// existing ones
    request.headers.addAll(
      Map<String, String>.from(defaultHeaders)..addAll(request.headers),
    );

    return _link.next(request);
  }

  /// Disposes all links.
  void dispose() => _link._forEach((link) => link.dispose());
}
