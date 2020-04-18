part of http_api;

class DebugLink extends ApiLink {
  final bool responseBody;
  final bool responseHeaders;
  final bool requestBody;
  final bool requestHeaders;
  final bool statusCode;
  final bool countRequests;
  final bool responseDuration;
  DebugLink({
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
      if (countRequests) {
        print("request count: ");
        print(_requestsCount);
        print("");
      }
      if (requestHeaders) {
        print("headers:\n");
        print(request?.headers);
        print("");
      }
      if (requestBody) {
        print("body:\n");
        print(request?.body);
        print("");
      }
      print("=================\n");
    }

    if (responseDuration) {
      _durations[_requestsCount] = DateTime.now();
    }

    final response = await super.next(request);

    if (responseBody || responseHeaders || statusCode || responseDuration) {
      print("\n==== RESPONSE ====\n");
      if (response != null) {
        if (responseDuration) {
          final responseDuration =
              _durations[_requestsCount].difference(DateTime.now());
          print("response duration: ${responseDuration.inMilliseconds}");
          _durations.remove(_requestsCount);
          print("");
        }
        if (responseHeaders) {
          print("headers:");
          print(response.headers);
          print("");
        }
        if (responseBody) {
          print("body:");
          print(response.body);
          print("");
        }
        if (statusCode) {
          print("status code:");
          print(response.statusCode);
          print("");
        }
      } else {
        print("NULL\n");
      }
      print("=================\n");
    }
    return response;
  }
}
