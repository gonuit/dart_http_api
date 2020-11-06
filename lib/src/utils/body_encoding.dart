part of http_api;

/// Returns the encoding that will be used for body parsing.
Encoding _getEncodingFromHeaders(Map<String, String> headers) {
  final mediaType = _getMediaTypeFromHeaders(headers);
  final charset = mediaType.parameters['charset'];
  final encoding = _getEncodingFromCharset(charset);
  return encoding;
}

/// Returns the [MediaType] object for the given headers's content-type.
/// Defaults to `application/octet-stream`.
MediaType _getMediaTypeFromHeaders(Map<String, String> headers) {
  var contentType = headers['content-type'];
  if (contentType != null) return MediaType.parse(contentType);
  return MediaType('application', 'octet-stream');
}

/// Returns the [Encoding] that corresponds to [charset].
/// Defaults to `latin1`.
Encoding _getEncodingFromCharset(String charset, [Encoding fallback = latin1]) {
  if (charset == null) return fallback;
  return Encoding.getByName(charset) ?? fallback;
}
