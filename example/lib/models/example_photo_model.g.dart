// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_photo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamplePhotoModel _$ExamplePhotoModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ExamplePhotoModel',
      json,
      ($checkedConvert) {
        final val = ExamplePhotoModel(
          id: $checkedConvert('id', (v) => v as String),
          author: $checkedConvert('author', (v) => v as String),
          width: $checkedConvert('width', (v) => v as int),
          height: $checkedConvert('height', (v) => v as int),
          url: $checkedConvert('url', (v) => v as String),
          downloadUrl: $checkedConvert('download_url', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {'downloadUrl': 'download_url'},
    );

Map<String, dynamic> _$ExamplePhotoModelToJson(ExamplePhotoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author': instance.author,
      'width': instance.width,
      'height': instance.height,
      'url': instance.url,
      'download_url': instance.downloadUrl,
    };
