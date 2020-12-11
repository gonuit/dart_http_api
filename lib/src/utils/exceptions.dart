part of http_api;

/// Base class for exceptions thrown from the http_api package.
class ApiException implements Exception {
  final String _message;

  String get message => _message;

  String toString() {
    if (message != null) {
      return "ApiException($message)";
    }
    return "ApiException()";
  }

  const ApiException(this._message);
}

class RequestException extends ApiException {
  final Response response;

  static String getMessageFromResponse(Response response) {
    final hasReasonPhrase = response.reasonPhrase?.isNotEmpty == true;
    final reasonPhrase = hasReasonPhrase ? ' (${response.reasonPhrase})' : '';

    return '${response.statusCode} '
        '${response.request.method.value} '
        '${response.request.endpoint}'
        '$reasonPhrase';
  }

  RequestException.fromResponse(this.response)
      : super(getMessageFromResponse(response));
}

/// Base class for exceptions thrown from the http_api package.
class ApiError extends Error {
  final String _message;

  String get message => _message;

  String toString() {
    if (message != null) {
      return "ApiError($message)";
    }
    return "ApiError()";
  }

  ApiError(this._message) : super();
}
