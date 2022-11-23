import 'dart:io';

import 'package:http_api/http_api.dart';
import 'package:test/test.dart';

void main() {
  group("FormData", () {
    final key1 = 'key1';
    final key2 = 'key2';
    final key3 = 'key3';
    final key4 = 'key4';

    final filename = "my_file.png";
    final file = File('./path/$filename');

    mapEntryEquals(MapEntry<String, dynamic> entry, String key, dynamic value) {
      expect(entry.key, equals(key));
      expect(entry.value, equals(value));
    }

    late FormData formData;

    setUp(() {
      formData = FormData();
      formData.append(key1, 1);
      formData.append(key1, '2');
      formData.append(key2, true);
      formData.appendFile(key3, file, filename: filename);
    });

    test("Appends FormData primitive values correctly.", () {
      expect(formData.entries, hasLength(4));
      mapEntryEquals(formData.entries[0], key1, '1');
      mapEntryEquals(formData.entries[1], key1, '2');
      mapEntryEquals(formData.entries[2], key2, 'true');

      final FileFieldWithFile fileField = formData.entries[3].value;
      mapEntryEquals(
        formData.entries[3],
        key3,
        isA<FileField>(),
      );

      expect(fileField.filename, filename);
      expect(fileField.contentType, isNull);
      expect(fileField.file, equals(file));
    });

    test("Deletes FormData entry correctly.", () {
      final keyToDelete = key1;
      expect(formData.entries, hasLength(4));

      formData.delete(key4);

      expect(formData.entries, hasLength(4));

      formData.delete(keyToDelete);

      expect(formData.entries, hasLength(2));

      for (final entry in formData.entries) {
        expect(entry.key, isNot(equals(keyToDelete)));
      }
    });

    test("Has method works correctly.", () {
      expect(formData.has(key1), isTrue);
      expect(formData.has(key2), isTrue);
      expect(formData.has(key3), isTrue);
      expect(formData.has(key4), isFalse);
    });

    test("keys accessor works correctly.", () {
      expect(formData.keys, equals([key1, key1, key2, key3]));
    });

    test("values accessor works correctly.", () {
      expect(
          formData.values,
          equals([
            '1',
            '2',
            'true',
            isA<FileField>(),
          ]));
    });

    test("set method works correctly.", () {
      final newValue = 'replaced';

      expect(formData.entries, hasLength(4));
      formData.set(key1, newValue);
      expect(formData.entries, hasLength(3));
      mapEntryEquals(formData.entries.last, key1, newValue);
    });

    test("FormData with primitive values serialization works correctly.", () {
      final json = formData.toJson();

      expect(
        json,
        equals({
          '__type': 'FORM_DATA',
          'entries': [
            ['key1', '1'],
            ['key1', '2'],
            ['key2', 'true'],
            [
              'key3',
              {'filename': filename, 'contentType': null}
            ]
          ]
        }),
      );

      final deserializedFormData = FormData.fromJson(json);

      expect(formData.keys, equals(deserializedFormData.keys));

      final deserializedValues = deserializedFormData.values.toList();
      expect(
          formData.values,
          equals([
            deserializedValues[0],
            deserializedValues[1],
            deserializedValues[2],
            // Files are not serialzed
            isNot(deserializedValues[3]),
          ]));

      expect(json, equals(deserializedFormData.toJson()));
    });
  });
}
