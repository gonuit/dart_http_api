part of http_api;

/// An abstract class that lets you create your own link
///
/// Each link should extend this method
abstract class ApiLink {
  /// Default constructor.
  ApiLink();

  /// Allows constructing the ApiLink instance in place by
  /// providing handlers.
  ///
  /// example:
  /// ```dart
  /// ApiLink.next((request, next) {
  ///   request.headers["x-Custom-Header"] = importantValue;
  ///   return next(request);
  /// });
  /// ```
  factory ApiLink.next(
    final NextHandler next, {
    final VoidFunction dispose,
    final VoidFunction init,
  }) = _InPlaceLink;

  /// [ApiLink]s keeps reference to the first [ApiLink] in chain
  /// to simplify chaining.
  ///
  /// Initialy set to this or null in release builds if `this` is a [DebugLink].
  /// Can be changed by [chain] method.
  ApiLink get _firstLink =>
      __firstLink ?? (isReleaseBuild && (this is DebugLink) ? null : this);
  @protected
  ApiLink __firstLink;
  ApiLink _nextLink;
  bool _disposed = false;
  bool get disposed => false;
  bool _attached = false;
  bool get attached => _attached;
  bool get chained => _nextLink != null;

  /// calls [callback] for every link in chain
  void _forEach(void Function(ApiLink) callback) {
    var lastLink = _firstLink ?? this;
    do {
      callback(lastLink);
      lastLink = lastLink._nextLink;
    } while (lastLink != null);
  }

  /// Returns first [ApiLink] that matches provided test function.
  ApiLink _firstWhere(bool test(ApiLink link)) {
    var lastLink = _firstLink ?? this;
    do {
      if (test(lastLink)) return lastLink;
      lastLink = lastLink._nextLink;
    } while (lastLink != null);
    return null;
  }

  /// Marks all ApiLinks in chain as attached to api instance
  /// by setting [attached] property to `true` and `api` property
  /// to api instance.
  ///
  /// The attached links can no longer be chained.
  void _closeChain(Uri apiUrl) {
    _forEach((link) {
      link._attached = true;

      if (link is HttpLink) {
        link._apiUrl = apiUrl;
      }
    });
  }

  @visibleForTesting
  bool get isReleaseBuild {
    var release = true;
    assert(!(release = false));
    return release;
  }

  /// Chain multiple links into one.
  /// throws [ApiError] when error occurs
  @nonVirtual
  ApiLink chain(ApiLink nextLink) {
    if (nextLink == null) {
      throw ApiError(
        "Cannot chain link $runtimeType with ${nextLink.runtimeType}\n"
        "nextLink cannot be null",
      );
    }

    if (attached || nextLink.attached) {
      throw ApiError(
        "Cannot chain link $runtimeType with ${nextLink.runtimeType}\n"
        "You cannot chain links after attaching to BaseApi",
      );
    }

    if (disposed || nextLink.disposed) {
      throw ApiError(
        "Cannot chain link $runtimeType with ${nextLink.runtimeType}\n"
        "You cannot chain disposed links",
      );
    }

    if (this is HttpLink) {
      throw ApiError(
        "Cannot chain link $runtimeType with ${nextLink.runtimeType}\n"
        "Adding link after http link will take no effect",
      );
    }

    /// Do not chain (skip) [DebugLink] in release build.
    if (isReleaseBuild) {
      if (this is DebugLink) return nextLink;
      if (nextLink is DebugLink) return this;
    }

    /// set [_firstLink] reference in [nextLink]
    nextLink.__firstLink = _firstLink;

    /// set reference to next link
    _nextLink = nextLink;

    return nextLink;
  }

  /// This method is called on every request.
  /// Calling `super.next` will cause invocation of `next` method
  /// in the next ApiLink in the chain (if present)
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
    assert(_disposed == false, "ApiLink cannot be disposed more than once.");
    _disposed = true;
  }
}
