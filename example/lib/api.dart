// define your api class
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http_api/http_api.dart';

import 'models/example_photo_model.dart';

class Api extends BaseApi {
  Api({
    @required Uri url,
    ApiLink link,
    Map<String, String> defaultHeaders,
  }) : super(
          url: url,
          defaultHeaders: defaultHeaders,
          link: link,
        );

  Stream<ExamplePhotoModel> getPhotoWithCache() async* {
    yield* sendWithCache(ApiRequest(
      key: Key("TEST"),
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
      key: Key("TEST"),
      endpoint: "/id/${Random().nextInt(50)}/info",
      method: HttpMethod.get,
    ));

    return ExamplePhotoModel.fromJson(json.decode(response.body));
  }
}
