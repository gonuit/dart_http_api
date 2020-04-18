part of http_api;

class DebugLink extends ApiLink {
  final String label;
  final bool url;
  final bool responseBody;
  final bool responseHeaders;
  final bool requestBody;
  final bool requestHeaders;
  final bool statusCode;
  final bool countRequests;
  final bool responseDuration;
  DebugLink({
    this.label,
    this.url = false,
    this.requestBody = false,
    this.requestHeaders = false,
    this.responseBody = false,
    this.responseHeaders = false,
    this.statusCode = false,
    this.countRequests = false,
    this.responseDuration = false,
  }) : assert(requestBody != null &&
            requestHeaders != null &&
            responseBody != null &&
            url != null &&
            responseHeaders != null &&
            statusCode != null &&
            responseDuration != null &&
            countRequests != null);

  int _requestsCount = 0;
  int get requestsCount => _requestsCount;

  final _durations = <int, DateTime>{};

  @override
  Future<ApiResponse> next(ApiRequest request) async {
    _requestsCount++;

    if (requestBody || requestHeaders || countRequests) {
      print("\n==== REQUEST ====\n");
      if (label != null) {
        print("label: $label\n");
      }

      if (url) {
        print("url:\n${request.url}\n");
      }

      if (countRequests) {
        print("request count: $_requestsCount\n");
      }

      if (requestHeaders) {
        print("headers:\n${request?.headers}\n");
      }

      if (requestBody) {
        print("body:\n${request?.body}\n");
      }

      print("=================\n");
    }

    if (responseDuration) {
      _durations[_requestsCount] = DateTime.now();
    }

    final response = await super.next(request);

    if (responseBody ||
        responseHeaders ||
        statusCode ||
        responseDuration ||
        url) {
      print("\n==== RESPONSE ====\n");

      if (label != null) {
        print("label: $label\n");
      }

      if (url) {
        print("url:\n${request.url}\n");
      }

      if (responseDuration) {
        final responseDuration =
            DateTime.now().difference(_durations[_requestsCount]);
        print("response duration: ${responseDuration.inMilliseconds} ms\n");
        _durations.remove(_requestsCount);
      }
      if (response != null) {
        if (responseHeaders) {
          print("headers:\n${response.headers}\n");
        }

        if (responseBody) {
          print("body:\n${response.body}\n");
        }

        if (statusCode) {
          print("status code: ${response.statusCode}\n");
        }
      } else {
        print("NULL\n");
      }
      print("=================\n");
    }
    return response;
  }
}
