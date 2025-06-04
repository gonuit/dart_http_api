part of http_api;

/// All character codes that are valid in multipart boundaries.
///
/// This is the intersection of the characters allowed in the `bcharsnospace`
/// production defined in [RFC 2046][] and those allowed in the `token`
/// production defined in [RFC 1521][].
///
/// [RFC 2046]: http://tools.ietf.org/html/rfc2046#section-5.1.1.
/// [RFC 1521]: https://tools.ietf.org/html/rfc1521#section-4
const List<int> boundaryCharacters = <int>[
  43,
  95,
  45,
  46,
  48,
  49,
  50,
  51,
  52,
  53,
  54,
  55,
  56,
  57,
  65,
  66,
  67,
  68,
  69,
  70,
  71,
  72,
  73,
  74,
  75,
  76,
  77,
  78,
  79,
  80,
  81,
  82,
  83,
  84,
  85,
  86,
  87,
  88,
  89,
  90,
  97,
  98,
  99,
  100,
  101,
  102,
  103,
  104,
  105,
  106,
  107,
  108,
  109,
  110,
  111,
  112,
  113,
  114,
  115,
  116,
  117,
  118,
  119,
  120,
  121,
  122
];

/// A regular expression that matches strings that are composed entirely of
/// ASCII-compatible characters.
final _asciiOnly = RegExp(r'^[\x00-\x7F]+$');

final _newlineRegExp = RegExp(r'\r\n|\r|\n');

/// Returns whether [string] is composed entirely of ASCII-compatible
/// characters.
bool isPlainAscii(String string) => _asciiOnly.hasMatch(string);

/// A `multipart/form-data` request.
///
/// Such a request has both string [fields], which function as normal form
/// fields, and (potentially streamed) binary [files].
///
/// This request automatically sets the Content-Type header to
/// `multipart/form-data`. This value will override any value set by the user.
class FormDataRequest extends http.BaseRequest {
  static const String _boundaryTag = 'http-api-boundary-';

  /// The total length of the multipart boundaries used when building the
  /// request body.
  static const int _boundaryLength = 70;

  static final Random _random = Random();
  final OnProgress? onProgress;

  bool _finalized = false;
  bool get isFinalized => _finalized;

  /// The form fields to send for this request.
  final List<MapEntry<String, dynamic>> _fields = [];

  /// The list of files to upload for this request.
  final _files = <http.MultipartFile>[];

  Future<void> setEntries(List<MapEntry<String, dynamic>> entries) async {
    if (isFinalized) {
      throw StateError('$runtimeType is already finalized.');
    }

    final multipartFilesFutures = entries
        .where((entry) => entry.value is FileField)
        .map((entry) => (entry.value as FileField).toMultipartFile(entry.key));

    final multipartFiles = await Future.wait(multipartFilesFutures);

    _files
      ..clear()
      ..addAll(multipartFiles.whereType<http.MultipartFile>());

    final fields = entries.where((entry) => !(entry.value is FileField));

    _fields
      ..clear()
      ..addAll(fields);
  }

  FormDataRequest(
    String method,
    Uri url, {
    this.onProgress,
  }) : super(method, url);

  /// The total length of the request body, in bytes.
  ///
  /// This is calculated from [fields] and [files] and cannot be set manually.
  @override
  int get contentLength {
    var length = 0;

    for (final entry in _fields) {
      length += '--'.length +
          _boundaryLength +
          '\r\n'.length +
          utf8.encode(_headerForField(entry.key, entry.value)).length +
          utf8.encode(entry.value).length +
          '\r\n'.length;
    }

    for (final file in _files) {
      length += '--'.length +
          _boundaryLength +
          '\r\n'.length +
          utf8.encode(_headerForFile(file)).length +
          file.length +
          '\r\n'.length;
    }

    return length + '--'.length + _boundaryLength + '--\r\n'.length;
  }

  @override
  set contentLength(int? value) {
    throw UnsupportedError(
      'Cannot set the contentLength property of '
      'multipart requests.',
    );
  }

  /// Freezes all mutable fields and returns a single-subscription [ByteStream]
  /// that will emit the request body.
  @override
  http.ByteStream finalize() {
    _finalized = true;

    final boundary = _boundaryString();
    headers['Content-Type'] = 'multipart/form-data; boundary=$boundary';
    super.finalize();

    final byteStream = http.ByteStream(_finalize(boundary));
    if (onProgress == null) {
      return byteStream;
    } else {
      final total = contentLength;
      var bytes = 0;

      final progressTransformer =
          StreamTransformer<List<int>, List<int>>.fromHandlers(
        handleData: (data, sink) {
          bytes += data.length;
          onProgress!(bytes, total);
          sink.add(data);
        },
      );
      final stream = byteStream.transform(progressTransformer);
      return http.ByteStream(stream);
    }
  }

  Stream<List<int>> _finalize(String boundary) async* {
    const line = [13, 10]; // \r\n
    final separator = utf8.encode('--$boundary\r\n');
    final close = utf8.encode('--$boundary--\r\n');

    for (var field in _fields) {
      yield separator;
      yield utf8.encode(_headerForField(field.key, field.value));
      yield utf8.encode(field.value);
      yield line;
    }

    for (final file in _files) {
      yield separator;
      yield utf8.encode(_headerForFile(file));
      yield* file.finalize();
      yield line;
    }
    yield close;
  }

  /// Returns the header string for a field.
  ///
  /// The return value is guaranteed to contain only ASCII characters.
  String _headerForField(String name, String value) {
    var header =
        'content-disposition: form-data; name="${_browserEncode(name)}"';
    if (!isPlainAscii(value)) {
      header = '$header\r\n'
          'content-type: text/plain; charset=utf-8\r\n'
          'content-transfer-encoding: binary';
    }
    return '$header\r\n\r\n';
  }

  /// Returns the header string for a file.
  ///
  /// The return value is guaranteed to contain only ASCII characters.
  String _headerForFile(http.MultipartFile file) {
    var header = 'content-type: ${file.contentType}\r\n'
        'content-disposition: form-data; name="${_browserEncode(file.field)}"';

    if (file.filename != null) {
      header = '$header; filename="${_browserEncode(file.filename!)}"';
    }
    return '$header\r\n\r\n';
  }

  /// Encode [value] in the same way browsers do.
  String _browserEncode(String value) {
    // http://tools.ietf.org/html/rfc2388 mandates some complex encodings for
    // field names and file names, but in practice user agents seem not to
    // follow this at all. Instead, they URL-encode `\r`, `\n`, and `\r\n` as
    // `\r\n`; URL-encode `"`; and do nothing else (even for `%` or non-ASCII
    // characters). We follow their behavior.
    return value.replaceAll(_newlineRegExp, '%0D%0A').replaceAll('"', '%22');
  }

  /// Returns a randomly-generated multipart boundary string
  String _boundaryString() {
    var list = List<int>.generate(
      _boundaryLength - _boundaryTag.length,
      (index) => boundaryCharacters[_random.nextInt(boundaryCharacters.length)],
      growable: false,
    );
    return '$_boundaryTag${String.fromCharCodes(list)}';
  }
}
