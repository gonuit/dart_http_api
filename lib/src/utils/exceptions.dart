part of http_api;

/// Base class for exceptions thrown from the http_api package.
class ApiException implements Exception {
  final String _message;

  String get message => _message;

  String toString() {
    if (message != null) {
      return "ApiException: $message";
    }
    return "ApiException occured.";
  }

  const ApiException(this._message);
}

/// Base class for exceptions thrown from the http_api package.
class ApiError extends Error {
  final String _message;

  String get message => _message;

  String toString() {
    if (message != null) {
      return "ApiError: $message";
    }
    return "ApiError occured.";
  }

  ApiError(this._message) : super();
}
