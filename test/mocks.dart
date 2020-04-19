import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http_api/http_api.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mockito/mockito.dart';

const testResponseHeaders = <String, String>{
  'authorization': 'token',
};

final Uri testUrl = Uri.parse("https://example.com/api");

class MockFileField extends FileField {
  MockFileField({
    @required String field,
    @required File file,
    String fileName,
    MediaType contentType,
  }) : super(
          field: field,
          file: file,
          fileName: fileName,
          contentType: contentType,
        );

  Future<http.MultipartFile> toMultipartFile() async {
    return null;
  }
}

class MockHttpClient extends Fake implements http.Client {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest httpRequest) async {
    return http.StreamedResponse(
      Stream<List<int>>.empty(),
      200,
      contentLength: 0,
      headers: testResponseHeaders,
      request: httpRequest,
    );
  }

  bool _closed = false;
  bool get closed => _closed;

  @override
  void close() {
    _closed = true;
  }
}

class TestApi extends BaseApi {
  TestApi({
    @required Uri url,
    ApiLink link,
    Map<String, String> defaultHeaders,
  }) : super(
          url: url,
          link: link,
          defaultHeaders: defaultHeaders,
        );
}
