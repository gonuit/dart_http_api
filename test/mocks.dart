import 'package:http_api/http_api.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';

const testResponseHeaders = <String, String>{'authorization': 'token'};

final Uri testUrl = Uri.parse("https://example.com/api");

class MockFileField extends Mock implements FileField {
  Future<http.MultipartFile> toMultipartFile() async {
    return null;
  }

  @override
  Map<String, dynamic> toMap() {
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
