part of http_api;

/// Base class for exceptions thrown from the http_api package.
class ApiException implements Exception {
  final String _message;

  String get message => _message;

  const ApiException(this._message);
}
