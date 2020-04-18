part of http_api;

class ApiRequest {
  Uri uri;
  HttpMethod method;
  Encoding encoding;
  bool multipart;
  dynamic body;

  /// Here you can assign your data that will be passed to the next link
  final Map<String, dynamic> linkData = {};
  final List<FileField> fileFields = [];
  final Map<String, String> headers = {};

  ApiRequest(
    this.uri,
    this.method, {
    Map<String, String> headers,
    List<FileField> fileFields,
    this.body,
    this.encoding,
    this.multipart,
  }) {
    if (fileFields != null) this.fileFields.addAll(fileFields);
    if (headers != null) this.headers.addAll(headers);
  }

  /// If [ApiRequest] contains files or [multipart] property is set to true
  /// [isMultipart] equals true
  bool get isMultipart => multipart == true || fileFields.isNotEmpty;

  /// Builds http request of proper type depending on `isMultiplart` accessor
  Future<ApiResponse> send(http.Client client) async {
    final httpRequest = await (isMultipart
        ? _buildMultipartHttpRequest()
        : _buildHttpRequest());

    http.StreamedResponse streamedResponse = await client.send(
      httpRequest,
    );

    http.Response httpResponse = await http.Response.fromStream(
      streamedResponse,
    );

    return ApiResponse.fromHttp(
      httpRequest,
      httpResponse,
    );
  }

  /// Builds [MultipartRequest]
  Future<http.BaseRequest> _buildMultipartHttpRequest() async {
    final request = http.MultipartRequest(method.value, uri)
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
  Future<http.BaseRequest> _buildHttpRequest() async {
    final request = http.Request(method.value, uri);

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

  @override
  String toString() => <String, dynamic>{
        "uri": uri,
        "body": body,
        "encoding": encoding,
        "fileFields": fileFields,
        "headers": headers,
        "linkData": linkData,
        "method": method.value,
        "multipart": multipart,
      }.toString();
}
