part of http_api;

typedef VoidFunction = void Function();
typedef NextFunction = Future<Response?>? Function(Request request);
typedef NextHandler = Future<Response> Function(
  Request request,
  NextFunction next,
);
typedef OnProgress = void Function(int bytesUploaded, int totalBytes);
