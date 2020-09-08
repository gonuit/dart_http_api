part of http_api;

typedef VoidFunction = void Function();
typedef NextFunction = Future<ApiResponse> Function(ApiRequest request);
typedef NextHandler = Future<ApiResponse> Function(
  ApiRequest request,
  NextFunction next,
);
