part of http_api;

class _InPlaceLink extends ApiLink {
  final NextHandler _next;
  final VoidFunction _dispose;

  _InPlaceLink(
    final NextHandler next, {
    final VoidFunction dispose,
    final VoidFunction init,
  })  : assert(
          next != null,
          'handler function cannot be null.',
        ),
        _dispose = dispose,
        _next = next {
    /// call init if defined
    init?.call();
  }

  @override
  Future<ApiResponse> next(ApiRequest request) {
    return _next(request, super.next);
  }

  @override
  void dispose() {
    /// call dispose if defined
    _dispose?.call();
    super.dispose();
  }
}
