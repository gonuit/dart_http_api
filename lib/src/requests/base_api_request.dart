part of http_api;

abstract class BaseApiRequest {
  /// Url is set by BaseApi class
  Uri _apiUrl;
  Uri get apiUrl => _apiUrl;
  Uri get url {
    assert(apiUrl != null, "url is not available before sending a request");
    return Uri(
      scheme: apiUrl.scheme,
      host: apiUrl.host,
      path: endpoint,
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );
  }

  String endpoint;
  HttpMethod method;
  Encoding encoding;
  bool multipart;
  dynamic body;

  /// Here you can assign your data that will be passed to the next link
  final Map<String, dynamic> linkData = {};
  final List<FileField> fileFields = [];
  final Map<String, String> headers = {};
  final Map<String, dynamic> queryParameters = {};

  /// If [BaseApiRequest] contains files or [multipart] property is set to true
  /// [isMultipart] equals true
  bool get isMultipart => multipart == true || fileFields.isNotEmpty;

  BaseApiRequest({
    @required this.method,
    @required this.endpoint,
    Map<String, String> headers,
    List<FileField> fileFields,
    Map<String, dynamic> queryParameters,
    this.body,
    this.encoding,
    this.multipart,
  }) : assert(
          endpoint != null && method != null,
          "endpoint and method arguments cannot be null",
        ) {
    if (fileFields != null) this.fileFields.addAll(fileFields);
    if (headers != null) this.headers.addAll(headers);
    if (queryParameters != null) this.queryParameters.addAll(queryParameters);
  }

  /// This function should return request that will be passed to http client and send to api.
  FutureOr<http.BaseRequest> buildRequest();

  Map<String, dynamic> toMap() => <String, dynamic>{
        "url": url,
        "body": body,
        "encoding": encoding,
        "fileFields": fileFields,
        "headers": headers,
        "linkData": linkData,
        "method": method.value,
        "multipart": multipart,
      };

  String toString() => "$runtimeType(${toMap()})";
}
