import 'package:json_annotation/json_annotation.dart';

part 'example_photo_model.g.dart';

@JsonSerializable(nullable: false, checked: true)
class ExamplePhotoModel {
  final String id;
  final String author;
  final int width;
  final int height;
  final String url;
  @JsonKey(name: 'download_url')
  final String downloadUrl;

  String get lowQualityImageUrl {
    final uri = Uri.parse(downloadUrl);
    final newUri = uri.replace(
      pathSegments: uri.pathSegments.sublist(0, uri.pathSegments.length - 2)
        ..add("300"),
    );
    return newUri.toString();
  }

  const ExamplePhotoModel({
    this.id,
    this.author,
    this.width,
    this.height,
    this.url,
    this.downloadUrl,
  });

  factory ExamplePhotoModel.fromJson(Map<String, dynamic> json) =>
      _$ExamplePhotoModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExamplePhotoModelToJson(this);
}
