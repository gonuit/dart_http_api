part of http_api;

/// A class to create readable "multipart/form-data" streams.
/// It can be used to submit forms and file uploads to http server.
class FormData extends ApiRequest {
  /// MapEntry<String, String | FileField>
  @override
  covariant List<MapEntry<String, dynamic>> body = [];

  final Map<String, String> _headers = {};

  /// This request automatically sets the Content-Type header to
  /// `multipart/form-data`. This value will override any value set by the user.
  @override
  Map<String, String> get headers {
    _headers['Content-Type'] = 'multipart/form-data';
    return _headers;
  }

  @override
  final bool multipart = true;
  @override
  final bool isMultipart = true;

  void append(String key, dynamic value) {
    ArgumentError.checkNotNull(key, 'key');

    if (value is File) {
      appendFile(key, value);
    } else if (value is num || value is bool) {
      _appendValue(key, value.toString());
    } else if (value is String || value is FileField || value == null) {
      _appendValue(key, value);
    } else {
      throw ArgumentError.value(
        value,
        'value',
        'Type ${value.runtimeType} is not valid form data value type.\n'
            'FormData supports: FileField, String, double, int, bool.',
      );
    }
  }

  void appendFile(
    String key,
    File file, {
    MediaType contentType,
    String filename,
  }) {
    ArgumentError.checkNotNull(key, 'key');
    ArgumentError.checkNotNull(file, 'file');

    final fileField = FileField(
      field: key,
      file: file,
      fileName: filename,
      contentType: contentType,
    );

    _appendValue(key, fileField);
  }

  void _appendValue(String key, dynamic value) {
    body.add(MapEntry(key, value));
  }

  void delete(String key) {
    ArgumentError.checkNotNull(key, 'key');

    body.removeWhere((entry) => entry.key == key);
  }

  /// Returns an [Iterable] allowing to go through all FormData entries.
  Iterable<MapEntry<String, dynamic>> get entries => body;

  /// Returns an [Iterable] allowing to go through all
  /// keys contained in this object.
  Iterable<String> get keys sync* {
    for (final entry in entries) {
      yield entry.key;
    }
  }

  /// Returns an [Iterable] allowing to go through all
  /// values contained in this object.
  Iterable<dynamic> get values sync* {
    for (final entry in entries) {
      yield entry.value;
    }
  }

  /// Returns an [Iterable] allowing to go through all
  /// files contained in this object.
  Iterable<dynamic> get files sync* {
    for (final entry in entries) {
      final value = entry.value;
      if (value is File) {
        yield value;
      }
    }
  }

  /// Returns a bool value stating whether a FormData
  /// object contains a certain key.
  bool has(String key) {
    ArgumentError.checkNotNull(key, 'key');

    return keys.contains(key);
  }

  /// Replaces value for an existing key inside a FormData object,
  /// or adds the key/value if it does not already exist.
  void set(String key, dynamic value) {
    ArgumentError.checkNotNull(key, 'key');

    delete(key);
    append(key, value);
  }
}
