import 'package:http_api/http_api.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

const testResponseHeaders = <String, String>{'authorization': 'token'};

final Uri testUrl = Uri.parse("https://example.com/api");

class MockFileField extends Mock implements FileField {
  Future<http.MultipartFile?> toMultipartFile(String field) async {
    return null;
  }

  @override
  Map<String, dynamic>? toJson() {
    return null;
  }
}

class MockHttpClient extends Fake implements http.Client {
  int sendCalledTimes = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest httpRequest) async {
    sendCalledTimes++;
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
    required Uri url,
    ApiLink? link,
    Map<String, String>? defaultHeaders,
  }) : super(
          url,
          link: link,
          defaultHeaders: defaultHeaders,
        );
}

class MockedCacheManager extends Mock implements CacheManager {}

class TestApiWithCache extends BaseApi with Cache {
  TestApiWithCache({
    required Uri url,
    ApiLink? link,
    Map<String, String>? defaultHeaders,
  }) : super(
          url,
          link: link,
          defaultHeaders: defaultHeaders,
        );

  @override
  CacheManager createCacheManager() {
    return MockedCacheManager();
  }
}
