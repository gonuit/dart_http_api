import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:http_api/http_api.dart';

import 'mocks.dart';

final testClient = MockHttpClient();
final ApiLink testLink = HttpLink(testClient);

void main() {
  TestApiWithCache testApi;

  test('Creates test api successfully', () {
    testApi = TestApiWithCache(
      url: testUrl,
      link: testLink,
    );
    expect(testApi, isNotNull);
    expect(testApi, isA<TestApiWithCache>());
    expect(testApi, isA<BaseApi>());
    expect(testApi, isA<Cache>());
    expect(testApi.url, equals(testUrl));
  });

  group("cacheAndNetwork method works correctly", () {
    test("Throws error when key is not provided to request", () async {
      reset(testApi.cache);
      final request = ApiRequest(endpoint: '/test');

      expect(
        () async {
          await for (final _ in testApi.cacheAndNetwork(request)) {}
        },
        throwsA(isA<ApiError>()),
      );
    });

    test("returns one response if cache is not available", () async {
      reset(testApi.cache);

      final key = CacheKey("TEST KEY");
      final request = ApiRequest(key: key, endpoint: '/test');

      final responses = List<ApiResponse>();
      await for (final response in testApi.cacheAndNetwork(request)) {
        responses.add(response);
      }
      expect(responses.length, equals(1));
      verify(testApi.cache.read(key)).called(1);
    });

    test("returns two responses if cache is not available", () async {
      reset(testApi.cache);

      final key = CacheKey("TEST KEY");
      final request = ApiRequest(key: key, endpoint: '/test');

      final response = await testApi.send(request);
      verify(testApi.cache.write(key, any)).called(1);

      reset(testApi.cache);

      when(testApi.cache.read(key)).thenReturn(response);

      final request2 = ApiRequest(key: key, endpoint: '/test');
      final responses = List<ApiResponse>();
      await for (final response in testApi.cacheAndNetwork(request2)) {
        responses.add(response);
      }
      verify(testApi.cache.read(key)).called(1);
      verify(testApi.cache.write(key, any)).called(1);
      expect(responses.length, equals(2));
      expect(responses[0], equals(response));
      expect(responses[1], isNot(equals(response)));
    });
  });

  group("cacheIfAvailable method works correctly", () {
    test("Throws error when key is not provided to request", () async {
      final request = ApiRequest(endpoint: '/test');

      expect(
        () async {
          await testApi.cacheIfAvailable(request);
        },
        throwsA(isA<ApiError>()),
      );
    });

    test("returns network response if cache is not available", () async {
      reset(testApi.cache);
      testClient.sendCalledTimes = 0;

      final key = CacheKey("TEST KEY");
      final request = ApiRequest(key: key, endpoint: '/test');

      when(testApi.cache.read(key)).thenReturn(null);

      await testApi.cacheIfAvailable(request);

      expect(testClient.sendCalledTimes, equals(1));
      verify(testApi.cache.read(key)).called(1);
      verify(testApi.cache.write(key, any)).called(1);
    });

    test("returns cache response if is already cached exists", () async {
      reset(testApi.cache);
      testClient.sendCalledTimes = 0;

      final key = CacheKey("TEST KEY");
      final request = ApiRequest(key: key, endpoint: '/test');

      final httpResponse = http.Response("", 200);

      final apiResponse = ApiResponse.fromHttp(request, null, httpResponse);

      when(testApi.cache.read(key)).thenReturn(apiResponse);

      final response = await testApi.cacheIfAvailable(request);

      expect(testClient.sendCalledTimes, equals(0));
      expect(response, equals(apiResponse));
      verify(testApi.cache.read(key)).called(1);
      verifyNever(testApi.cache.write(key, any)).called(0);
    });
  });

  test("shouldUpdateCache works correctly", () {
    final key = CacheKey("TEST KEY");
    var request = ApiRequest(key: key, endpoint: '/test');
    var httpResponse = http.Response("", 200);
    var apiResponse = ApiResponse.fromHttp(request, null, httpResponse);

    expect(testApi.shouldUpdateCache(request, apiResponse), isTrue);

    httpResponse = http.Response("", 400);
    apiResponse = ApiResponse.fromHttp(request, null, httpResponse);

    expect(testApi.shouldUpdateCache(request, apiResponse), isFalse);

    request = ApiRequest(endpoint: '/test');
    httpResponse = http.Response("", 200);
    apiResponse = ApiResponse.fromHttp(request, null, httpResponse);

    expect(testApi.shouldUpdateCache(request, apiResponse), isFalse);
  });

  test("dispose works correctly", () {
    reset(testApi.cache);
    testApi.dispose();
    verify(testApi.cache.dispose()).called(1);
  });
}
