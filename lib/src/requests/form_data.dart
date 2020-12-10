part of http_api;

/// A class to create readable "multipart/form-data" streams.
/// It can be used to submit forms and file uploads to http server.
class FormData with Serializable {
  // MapEntry<String, String | FileField>
  /// Returns an [Iterable] allowing to go through all FormData entries.
  final List<MapEntry<String, dynamic>> entries = [];

  FormData();

  FormData.fromEntries(List<MapEntry<String, dynamic>> entries) {
    /// use loop with [append] method to copy map entries
    /// and check types.
    for (final entry in entries) {
      append(entry.key, entry.value);
    }
  }

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
      file: file,
      fileName: filename,
      contentType: contentType,
    );

    _appendValue(key, fileField);
  }

  void _appendValue(String key, dynamic value) {
    entries.add(MapEntry(key, value));
  }

  void delete(String key) {
    ArgumentError.checkNotNull(key, 'key');

    entries.removeWhere((entry) => entry.key == key);
  }

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

  /// Serialize FormData to json.
  ///
  /// Important: Files will be skipped.
  /// Only file description will be included.
  Map<String, dynamic> toJson() {
    final serializedEntries = entries.map((entry) {
      if (entry is FileField) {
        final FileField value = entry.value;
        return {entry.key: value.toJson()};
      } else {
        return {entry.key: entry.value};
      }
    });

    return {
      _bodyTypeKey: DataType.formData.value,
      "entries": serializedEntries,
    };
  }

  /// Deserialize FormData from json.
  factory FormData.fromJson(dynamic json) {
    if (json == null ||
        !(json is Map) ||
        json.type != DataType.formData.value ||
        json.entries == null ||
        !(json.entries is List)) {
      throw ArgumentError.value(
        json,
        'json',
        'Provided value is not a valid FormData json.',
      );
    }

    return FormData.fromEntries(json.entries);
  }
}
