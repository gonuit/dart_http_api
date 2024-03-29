// define your api class
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http_api/http_api.dart';

import 'models/example_photo_model.dart';

class Api extends BaseApi with Cache {
  Api({
    required Uri url,
    ApiLink? link,
  }) : super(url, link: link);

  @override
  CacheManager createCacheManager() => InMemoryCache();

  Stream<ExamplePhotoModel> getPhotoWithCache() {
    final request = Request(
      key: const CacheKey("TEST"),
      endpoint: "/id/${129}/info",
    );

    final transformResponseToExamplePhotoModel =
        StreamTransformer<Response, ExamplePhotoModel>.fromHandlers(
      handleData: (response, sink) => sink.add(
        ExamplePhotoModel.fromJson(json.decode(response.body)),
      ),
    );

    return cacheAndNetwork(request)
        .transform(transformResponseToExamplePhotoModel);
  }

  /// Implement api request methods
  Future<ExamplePhotoModel> getRandomPhoto() async {
    /// Use [send] method to make api request
    final response = await get("/id/${Random().nextInt(50)}/info");

    return ExamplePhotoModel.fromJson(json.decode(response.body));
  }
}
