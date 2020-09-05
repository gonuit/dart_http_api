part of http_api;

/// ApiLink that is mixed witch ChangeNotifier
abstract class NotifierApiLink extends ApiLink with ChangeNotifier {}

/// An abstract class that lets you create your own link
///
/// Each link should extend this method
abstract class ApiLink {
  /// [ApiLink]s keeps reference to the first [ApiLink] in chain to simplify chaining
  ApiLink _firstLink;
  ApiLink _nextLink;
  bool _disposed = false;
  bool get disposed => false;
  bool _closed = false;
  bool get closed => _closed;
  bool get chained => _nextLink != null;

  /// calls [callback] for every link in chain
  void _forEach(ValueChanged<ApiLink> callback) {
    ApiLink lastLink = _firstLink ?? this;
    do {
      callback(lastLink);
      lastLink = lastLink._nextLink;
    } while (lastLink != null);
  }

  /// Returns first [ApiLink] that matches provided test function.
  ApiLink _firstWhere(bool test(ApiLink link)) {
    ApiLink lastLink = _firstLink ?? this;
    do {
      if (test(lastLink)) return lastLink;
      lastLink = lastLink._nextLink;
    } while (lastLink != null);
    return null;
  }

  /// Closes all links
  void _closeChain() {
    /// If [_firstLink] is not set, it will be set with [this].
    /// Close link chain.
    _firstLink ??= this;
    _forEach((ApiLink link) {
      link._closed = true;
    });
  }

  /// Chain multiple links into one.
  @nonVirtual
  ApiLink chain(ApiLink nextLink) {
    if (nextLink == null)
      throw ApiException(
        "Cannot chain link $runtimeType with ${nextLink.runtimeType}\n"
        "nextLink cannot be null",
      );

    if (closed || nextLink.closed)
      throw ApiException(
        "Cannot chain link $runtimeType with ${nextLink.runtimeType}\n"
        "You cannot chain links after attaching to BaseApi",
      );

    if (disposed || nextLink.disposed)
      throw ApiException(
        "Cannot chain link $runtimeType with ${nextLink.runtimeType}\n"
        "You cannot chain disposed links",
      );

    if (this is HttpLink)
      throw ApiException(
        "Cannot chain link $runtimeType with ${nextLink.runtimeType}\n"
        "Adding link after http link will take no effect",
      );

    bool isReleaseBuild = true;
    assert(!(isReleaseBuild = false));

    /// Do not chain (skip) [DebugLink] in release build.
    if (nextLink is DebugLink && isReleaseBuild) return this;

    /// If there is no chain, start it with current
    if (_firstLink == null) {
      _firstLink = this;
    }

    /// set [_firstLink] reference in [nextLink]
    nextLink._firstLink = _firstLink;

    /// set reference to next link
    _nextLink = nextLink;

    return nextLink;
  }

  /// This method is called on every request.
  /// Calling `super.next` will cause invocation of `next` method in the next ApiLink
  /// in the chain (if present)
  @protected
  Future<ApiResponse> next(ApiRequest request) {
    return _nextLink?.next(request);
  }

  /// Called when API object has been disposed
  ///
  /// Here you can frees up your resources
  ///
  /// TIP:
  /// To initialize your ApiLink data you can use constructor body.
  @mustCallSuper
  void dispose() {
    assert(_disposed == false, "ApiLink cannot be disposed more than once");
    _disposed = true;
  }

  @override
  String toString() => "ApiLink: ${this.runtimeType}";
}
