part of http_api;

class GraphQlRequest extends ApiRequest {}

class GraphQlResponse extends ApiResponse {
  GraphQlResponse.fromHttp(http.BaseRequest request, http.Response response,
      Map<String, void> linkData)
      : super.fromHttp(request, response, linkData);
}

class BaseGraphQlApi extends BaseApi {
  /// Make API request by triggering [ApiLink]s [next] methods
  @override
  Future<GraphQlResponse> send(covariant GraphQlRequest request) {
    /// Adds default headers to the request, but does not overrides existing ones
    request.headers.addAll(
      Map<String, String>.from(defaultHeaders)..addAll(request.headers),
    );

    /// Sets request api url
    request._apiUrl = url;

    return _link.next(request);
  }
}
