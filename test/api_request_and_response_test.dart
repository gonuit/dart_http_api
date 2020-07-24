import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http_api/http_api.dart';

import 'mocks.dart';

final testClient = MockHttpClient();

const Map<String, String> testDefaultHeaders = <String, String>{};
final ApiLink testLink = HttpLink(testClient);

void main() {
  TestApi testApi;
  test('Creates test api succesfully', () {
    testApi = TestApi(
      url: testUrl,
      defaultHeaders: testDefaultHeaders,
      link: testLink,
    );
    expect(testApi, isNotNull);
    expect(testApi, isInstanceOf<TestApi>());
    expect(testApi, isInstanceOf<BaseApi>());
    expect(testApi.url, equals(testUrl));
    expect(testApi.defaultHeaders, equals(testDefaultHeaders));
  });

  test("HttpMethod returns correct values", () {
    expect(HttpMethod.get.value, equals("GET"));
    expect(HttpMethod.post.value, equals("POST"));
    expect(HttpMethod.delete.value, equals("DELETE"));
    expect(HttpMethod.head.value, equals("HEAD"));
    expect(HttpMethod.patch.value, equals("PATCH"));
    expect(HttpMethod.put.value, equals("PUT"));
  });

  test("BaseApi sets requests url correctly", () async {
    final apiRequest = ApiRequest(endpoint: '/test');
    testApi.send(apiRequest);
    final httpRequest = await apiRequest.buildRequest();

    expect(httpRequest.url, equals(Uri.parse("https://example.com/api/test")));
  });

  test("Build ApiRequest with default method", () async {
    final apiRequest = ApiRequest(endpoint: '/test');
    testApi.send(apiRequest);
    final httpRequest = await apiRequest.buildRequest();

    expect(httpRequest.method, apiRequest.method.value);
    expect(httpRequest.method, HttpMethod.get.value);
  });

  test("linkData is passed correctly", () async {
    final apiRequest = ApiRequest(endpoint: '/test');
    apiRequest.linkData["test"] = "data";
    testApi.send(apiRequest);

    final response = await testApi.send(apiRequest);

    expect(response.linkData["test"], equals("data"));
  });

  test("ApiRequests with files are multipart", () async {
    final apiRequest = ApiRequest(
      endpoint: '/file',
      method: HttpMethod.post,
      fileFields: [
        MockFileField(),
      ],
    );

    expect(apiRequest.isMultipart, isTrue);

    await testApi.send(apiRequest);
    final httpRequest = await apiRequest.buildRequest();

    expect(httpRequest, isInstanceOf<http.MultipartRequest>());
  });

  test("ApiRequests without files are not multipart", () async {
    final apiRequest = ApiRequest(
      endpoint: '/file',
      method: HttpMethod.post,
    );

    expect(apiRequest.isMultipart, isFalse);

    await testApi.send(apiRequest);
    final httpRequest = await apiRequest.buildRequest();

    expect(httpRequest, isInstanceOf<http.Request>());
  });
}
