part of http_api;

/// LoggerLink is DebugLink that prints request details to console.
/// 
/// {@macro http_api.debug_link}
class LoggerLink extends DebugLink {
  final String label;
  final bool url;
  final bool responseBody;
  final bool responseHeaders;
  final bool requestBody;
  final bool requestHeaders;
  final bool statusCode;
  final bool countRequests;
  final bool responseDuration;
  LoggerLink({
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

  final _durations = <ObjectId, DateTime>{};

  void _printRequest(ApiRequest request) {
    /// print request only in debug mode
    assert((() {
      if (requestBody || requestHeaders || countRequests || url) {
        print("\n==== REQUEST ====\n");

        print("request id: ${request.id}\n");

        if (label != null) {
          print("label: $label\n");
        }

        if (url) {
          print("url: ${request.url}\n");
        }

        if (countRequests) {
          print("request count: $_requestsCount\n");
        }

        if (requestHeaders) {
          print("headers: ${request?.headers}\n");
        }

        if (requestBody) {
          print("body: ${request?.body}\n");
        }

        print("=================\n");
      }

      return true;
    })());
  }

  void _printResponse(ApiResponse response) {
    /// print request only in debug mode
    assert((() {
      if (responseBody ||
          responseHeaders ||
          statusCode ||
          responseDuration ||
          url) {
        print("\n==== RESPONSE ====\n");

        print("request id: ${response.id}\n");

        if (label != null) {
          print("label: $label\n");
        }

        if (url) {
          print("url: ${response.request.url}\n");
        }

        if (responseDuration) {
          final responseDuration =
              DateTime.now().difference(_durations[response.id]);
          print("response duration: ${responseDuration.inMilliseconds} ms\n");
          _durations.remove(response.id);
        }
        if (response != null) {
          if (responseHeaders) {
            print("headers: ${response.headers}\n");
          }

          if (responseBody) {
            print("body: ${response.body}\n");
          }

          if (statusCode) {
            print("status code: ${response.statusCode}\n");
          }
        } else {
          print("NULL\n");
        }
        print("=================\n");
      }

      return true;
    })());
  }

  @override
  Future<ApiResponse> next(ApiRequest request) async {
    _requestsCount++;

    _printRequest(request);

    if (responseDuration) {
      _durations[request.id] = DateTime.now();
    }

    final response = await super.next(request);

    _printResponse(response);

    return response;
  }
}