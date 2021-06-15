part of http_api;

class _InPlaceLink extends ApiLink {
  final NextHandler _next;
  final VoidFunction? _dispose;

  _InPlaceLink(
    final NextHandler next, {
    final VoidFunction? dispose,
    final VoidFunction? init,
  })  : _dispose = dispose,
        _next = next {
    /// call init if defined
    init?.call();
  }

  @override
  Future<Response> next(Request request) {
    return _next(request, super.next);
  }

  @override
  void dispose() {
    /// call dispose if defined
    _dispose?.call();
    super.dispose();
  }
}
