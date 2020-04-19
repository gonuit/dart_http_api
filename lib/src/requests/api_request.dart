part of http_api;

class ApiRequest extends BaseApiRequest {
  ApiRequest({
    @required HttpMethod method,
    @required String endpoint,
    Map<String, String> headers,
    List<FileField> fileFields,
    Map<String, dynamic> queryParameters,
    dynamic body,
    Encoding encoding,
    bool multipart,
  }) : super(
          endpoint: endpoint,
          method: method,
          headers: headers,
          fileFields: fileFields,
          body: body,
          encoding: encoding,
          multipart: multipart,
          queryParameters: queryParameters,
        );

  @override
  FutureOr<http.BaseRequest> buildRequest() {
    if (url == null) {
      throw ApiException("$runtimeType url cannot be null");
    }
    return isMultipart ? _buildMultipartHttpRequest() : _buildHttpRequest();
  }

  /// Builds [MultipartRequest]
  Future<http.BaseRequest> _buildMultipartHttpRequest() async {
    final request = http.MultipartRequest(method.value, url)
      ..headers.addAll(headers);

    /// Assign body if it is map
    if (body != null) {
      if (body is Map)
        request.fields.addAll(body.cast<String, String>());
      else
        throw ArgumentError(
          'Invalid request body "$body".\n'
          'Multipart request body should be Map<String, String>',
        );
    }

    /// Assign files to [MultipartRequest]
    for (final fileField in fileFields)
      request.files.add(await fileField.toMultipartFile());

    return request;
  }

  /// Buils [Request]
  http.BaseRequest _buildHttpRequest() {
    final request = http.Request(method.value, url);

    if (headers != null) request.headers.addAll(headers);
    if (encoding != null) request.encoding = encoding;
    if (body != null) {
      if (body is String)
        request.body = body;
      else if (body is List)
        request.bodyBytes = body.cast<int>();
      else if (body is Map)
        request.bodyFields = body.cast<String, String>();
      else
        throw ArgumentError('Invalid request body "$body".');
    }
    return request;
  }
}
