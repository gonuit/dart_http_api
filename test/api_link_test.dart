import 'package:test/test.dart';
import 'package:http_api/http_api.dart';

import 'mocks.dart';

class TestLink extends ApiLink {
  final int id;
  TestLink(this.id);

  int requestNumber;
  int responseNumber;
  bool _called = false;
  bool get called => _called;

  @override
  Future<ApiResponse> next(ApiRequest request) async {
    _called = true;
    int linkCounter = request.linkData["linkCounter"] ?? 0;
    requestNumber = request.linkData["linkCounter"] = ++linkCounter;

    final response = await super.next(request);

    if (response == null) return response;

    linkCounter = response.linkData["linkCounter"];
    responseNumber = response.linkData["linkCounter"] = ++linkCounter;

    return response;
  }

  bool _disposed = false;
  bool get disposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class BreakRequestPropagationLink extends ApiLink {
  @override
  Future<ApiResponse> next(ApiRequest request) async {
    return null;
  }
}

void main() {
  ApiLink apiLink;
  final link1 = TestLink(1);
  final link2 = TestLink(2);
  final link3 = TestLink(3);
  final link4 = TestLink(4);
  test('Chains links correctly', () {
    apiLink = link1
        .chain(link2)
        .chain(link3)
        .chain(link4)
        .chain(HttpLink(MockHttpClient()));
  });

  test("Cannot chain ApiLinks after http link", () {
    ApiError error;
    try {
      apiLink.chain(TestLink(99));
      // ignore: avoid_catching_errors
    } on ApiError catch (err) {
      error = err;
    }
    expect(error, isNotNull);
    expect(
        error.message,
        equals(
          "Cannot chain link HttpLink with TestLink\n"
          "Adding link after http link will take no effect",
        ));
  });

  test("ApiLinks are called in proper order", () async {
    final api = TestApi(
      url: testUrl,
      link: apiLink,
    );

    final apiRequest = ApiRequest(endpoint: '/test');

    await api.send(apiRequest);

    expect(link1.requestNumber, equals(1));
    expect(link2.requestNumber, equals(2));
    expect(link3.requestNumber, equals(3));
    expect(link4.requestNumber, equals(4));
    expect(link4.responseNumber, equals(5));
    expect(link3.responseNumber, equals(6));
    expect(link2.responseNumber, equals(7));
    expect(link1.responseNumber, equals(8));
  });

  test("Cannot reasing ApiLink chain to another api", () async {
    ApiError error;
    try {
      TestApi(
        url: testUrl,
        link: apiLink,
      );
      // ignore: avoid_catching_errors
    } on ApiError catch (err) {
      error = err;
    }

    expect(error, isNotNull);
    expect(error.message,
        equals("Cannot reattach already attached ApiLink to TestApi."));
  });

  test("BaseApi dispose method, disposes all links", () async {
    final link1 = TestLink(1);
    final link2 = TestLink(2);
    final link3 = TestLink(3);
    final link4 = TestLink(4);
    final mockClient = MockHttpClient();
    final httpLink = HttpLink(mockClient);
    final api = TestApi(
      url: testUrl,
      link: link1.chain(link2).chain(link3).chain(link4).chain(httpLink),
    );

    expect(link1.disposed, isFalse);
    expect(link2.disposed, isFalse);
    expect(link3.disposed, isFalse);
    expect(link4.disposed, isFalse);
    expect(mockClient.closed, isFalse);

    api.dispose();

    expect(link1.disposed, isTrue);
    expect(link2.disposed, isTrue);
    expect(link3.disposed, isTrue);
    expect(link4.disposed, isTrue);
    expect(mockClient.closed, isTrue);
  });

  test("Cannot chain ApiLinks after attaching to BaseApi", () {
    ApiError error;
    try {
      apiLink.chain(TestLink(99));
      // ignore: avoid_catching_errors
    } on ApiError catch (err) {
      error = err;
    }
    expect(error, isNotNull);
    expect(
        error.message,
        equals(
          "Cannot chain link HttpLink with TestLink\n"
          "You cannot chain links after attaching to BaseApi",
        ));
  });

  test("Cannot attach ApiLinks chain without HttpLink", () {
    ApiError error;
    try {
      TestApi(url: testUrl, link: TestLink(1).chain(TestLink(2)));
      // ignore: avoid_catching_errors
    } on ApiError catch (err) {
      error = err;
    }
    expect(error, isNotNull);
    expect(error.message, equals("ApiLinks chain should contain HttpLink."));
  });

  test(
    'Not calling super in ApiLink next method prevent request propagation',
    () async {
      final link1 = TestLink(1);
      final link2 = TestLink(2);
      final link3 = BreakRequestPropagationLink();
      final link4 = TestLink(4);
      final mockClient = MockHttpClient();
      final httpLink = HttpLink(mockClient);
      final api = TestApi(
        url: testUrl,
        link: link1.chain(link2).chain(link3).chain(link4).chain(httpLink),
      );
      final apiRequest = ApiRequest(endpoint: '/test');
      final response = await api.send(apiRequest);

      expect(response, isNull);
      expect(link1.called, isTrue);
      expect(link2.called, isTrue);
      expect(link4.called, isFalse);
    },
  );
}
