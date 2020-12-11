part of http_api;

/// A class to create readable "multipart/form-data" streams.
/// It can be used to submit forms and file uploads to http server.
class FormData with Serializable {
  /// Returns an [Iterable] allowing to go through all [FormData] entries.
  ///
  /// MapEntry<String, String | FileField>
  final List<MapEntry<String, dynamic>> entries = [];

  FormData();

  FormData.fromEntries(List<MapEntry<String, dynamic>> entries) {
    /// use loop with [append] method to copy map entries
    /// and check types.
    for (final entry in entries) {
      append(entry.key, entry.value);
    }
  }

  /// Appends a new value onto an existing key inside a FormData object,
  /// or adds the key if it does not already exist.
  ///
  /// To append File with additional settings like: `filename`, you can use
  /// [appendFile] method or pass [FileField] to [append] method.
  void append(String key, dynamic value) {
    ArgumentError.checkNotNull(key, 'key');

    if (value is File) {
      appendFile(key, value);
    } else if (value is num || value is bool) {
      _addEntry(key, value.toString());
    } else if (value is String || value is FileField || value == null) {
      _addEntry(key, value);
    } else {
      throw ArgumentError.value(
        value,
        'value',
        'Type ${value.runtimeType} is not valid form data value type.\n'
            'FormData supports: File, FileField, String, double, int, bool.',
      );
    }
  }

  /// Appends a new file onto an existing key inside a FormData object,
  /// or adds the key if it does not already exist.
  /// In opposite to the [append] method,
  /// it has additional settings related to the file.
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
      filename: filename,
      contentType: contentType,
    );

    _addEntry(key, fileField);
  }

  void _addEntry(String key, dynamic value) {
    entries.add(MapEntry(key, value));
  }

  /// Deletes a key/value pair from a FormData object.
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
      if (entry.value is FileField) {
        final FileField value = entry.value;
        return [entry.key, value.toJson()];
      } else {
        return [entry.key, entry.value];
      }
    });

    return {
      _bodyTypeKey: DataType.formData.value,
      "entries": serializedEntries,
    };
  }

  /// Deserialize [FormData] from json.
  factory FormData.fromJson(dynamic json) {
    if (json == null ||
        !(json is Map) ||
        json[_bodyTypeKey] != DataType.formData.value ||
        json['entries'] == null ||
        !(json['entries'] is Iterable)) {
      throw ArgumentError.value(
        json,
        'json',
        'Provided value is not a valid FormData json.',
      );
    }

    final formData = FormData();

    for (final entry in json['entries']) {
      final key = entry[0];
      final value = entry[1];

      if (value is String) {
        formData.append(key, value);
      } else {
        formData.append(key, FileField.fromJson(value));
      }
    }

    return formData;
  }
}
