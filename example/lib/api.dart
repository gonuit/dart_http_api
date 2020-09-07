// define your api class
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http_api/http_api.dart';

import 'models/example_photo_model.dart';

class Api extends BaseApi with Cache {
  Api({
    @required Uri url,
    ApiLink link,
  }) : super(
          url: url,
          link: link,
        );

  @override
  CacheManager createCacheManager() => InMemoryCache();

  Stream<ExamplePhotoModel> getPhotoWithCache() async* {
    yield* cacheAndNetwork(ApiRequest(
      key: CacheKey("TEST"),
      endpoint: "/id/${129}/info",
      method: HttpMethod.get,
    )).transform<ExamplePhotoModel>(StreamTransformer.fromHandlers(
        handleData: (ApiResponse response, sink) {
      sink.add(ExamplePhotoModel.fromJson(json.decode(response.body)));
    }));
  }

  /// Implement api request methods
  Future<ExamplePhotoModel> getRandomPhoto() async {
    /// Use [send] method to make api request
    final response = await send(ApiRequest(
      endpoint: "/id/${Random().nextInt(50)}/info",
      method: HttpMethod.get,
    ));

    return ExamplePhotoModel.fromJson(json.decode(response.body));
  }
}
