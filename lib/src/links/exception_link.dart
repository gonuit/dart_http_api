import '../../http_api.dart';

class ExceptionLink extends ApiLink {
  @override
  Future<Response> next(Request request) async {
    final response = await super.next(request);

    if (response.ok) {
      return response;
    } else {
      final exception = RequestException.fromResponse(response);

      assert(() {
        print(
          '[$runtimeType DEBUG]: Exeption thrown: '
          '${exception.runtimeType}(\'${exception.message}\')',
        );
        return true;
      }());

      throw exception;
    }
  }
}
