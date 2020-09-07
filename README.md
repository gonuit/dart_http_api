# http_api
  
[![Codemagic build status](https://api.codemagic.io/apps/5e9c9c7a7af7f3ae2a99d6a0/5e9c9c7a7af7f3ae2a99d69f/status_badge.svg)](https://codemagic.io/apps/5e9c9c7a7af7f3ae2a99d6a0/5e9c9c7a7af7f3ae2a99d69f/latest_build)
![Pub Version](https://img.shields.io/pub/v/http_api?color=%230175c2)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
  
Simple yet powerful wrapper around http package inspired by apollo graphql links. This package provides you a simple way of adding middlewares to your app http requests.

## IMPORTANT
This library is under development, breaking API changes might still happen. If you would like to make use of this library please make sure to provide which version you want to use e.g:
```yaml
dependencies:
  http_api: 0.7.0
```

## Getting Started

#### 1. Create your Api class by extending `BaseApi` class.
```dart
// define your api class
class Api extends BaseApi {

  /// Provide the BaseApi constructor with the data you need,
  /// by calling super method.
  Api(Uri url) : super(url);

  /// Implement api request methods...
  Future<PostModel> getPostById(int id) async {

    /// Use [send] method to make api request
    final response = await send(ApiRequest(
      endpoint: "/posts/$id",
    ));

    /// Do something with your data. 
    /// e.g: Parse HTTP response to the model of your choice.
    return PostModel.fromJson(response.body);
  }
}
```

#### 2. Play with it!
```dart
void main() async {
  /// Define api base url.
  final url = Uri.parse("https://example.com/api");

  /// Create api instance
  final api = Api(url);
  
  /// Make a request
  Post post = await api.getPostById(10);

  /// Do something with your data 🚀
  print(post.title);

  /// 🔥 You are ready for rocking! 🔥
}
```

## http_api and Flutter ♥️.
http_api package works well with both Dart and Flutter projects.

#### TIP: You can provide your Api instance down the widget tree using [provider](https://pub.dev/packages/provider) package.
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Provider(
        create: (_) => Api(
          Uri.parse("https://example.com/api"),
          /// Assign middlewares by providing ApiLinks (to provide more than one middlewares, chain them)
          link: AuthLink()
              .chain(DebugLink(responseBody: true)),
              .chain(HttpLink()),
        ),
        /// Your app
        child: MaterialApp(
          title: 'my_app',
          onGenerateRoute: _generateRoute,
        ),
      );
  }
}
```

## Cache
With http_api you can cache your responses to avoid uneccesary fetches or/and improve user experience.
  
### To add cache to your existing Api class.
#### 1. Add `Cache` mixin on it.
```diff
- class Api extends BaseApi {
+ class Api extends BaseApi with Cache {

  /// ** your custom Api class implementation **
}
```
#### 2. Provide a Api class with cache manager of your choice.
```dart
class Api extends BaseApi with Cache {

  /// Provide a cache manager of your choice.
  /// This lib provides you with in memory cache manager implementation.
  @override
  CacheManager createCacheManager() => InMemoryCache();

  /// ** Your custom Api class implementation **
}
```
#### 3. That's all!
Now you can take advantage of response caching.
  
### Cache mixin.
Cache mixin adds `cacheAndNetwork` and `cacheIfAvailable` methods to your api instance, together with the cache manager which is accessible via `cache` property.
  
By default, each request that contains `key` argument for which response was successful; will automatically update the cache. To decide what should be saved into the cache, override `shouldUpdateCache` method.

#### `cacheIfAvailable`
Retrieve response from the cache,  if not available fallback to the network.  
Returns `Future<ApiResponse>` type.

#### `cacheAndNetwork`
Retrieve response from the cache if available and then from the network.  Returns `Stream<ApiResponse>` type.
  
Example:
```dart
// Api.dart
class Api extends BaseApi with Cache {

  @override
  CacheManager createCacheManager() => InMemoryCache();

  Stream<PostModel> getPostById(int id) {
    Stream<PostModel> request = ApiRequest(
      /// Key argument is required for caching.
      /// Response will be cached and retrieved from the following key.
      key: CacheKey("posts/$id"),
      endpoint: "/posts/${id}",
    );
    
    /// Because `cacheAndNetwork` method returns Stream, we can take
    /// advantage of all it's features.
    /// e.g: Transform responses to the models of your choice.
    final transformResponseToPostModel =
        StreamTransformer<ApiResponse, PostModel>.fromHandlers(
      handleData: (response, sink) => sink.add(
        PostModel.fromJson(response.body),
      ),
    );

    /// Now you can return transformed stream from this function
    return cacheAndNetwork(request)
        .transform(transformResponseToPostModel);
  }

  /// ** Your custom Api class implementation **
}
```

#### `cache`
Cache property contains a `CacheManager` instance that was internally created via the `createCacheManager` method. Thanks to this property, you can manipulate your cache by yourself.
  
Example:
```dart
/// Saves a new response to the cache and retrieve previously saved.
ApiResponse saveResponseToCache(CacheKey key, ApiResponse response) async {
  final oldResponse = await api.cache.read(key);
  await api.cache.write(key, response);
  return oldResponse;
}
```

#### `shouldUpdateCache` 
Decide whether response related to request should be saved to the cache.

Default implementation:
```dart
bool shouldUpdateCache(ApiRequest request, ApiResponse response) {
 return request.key != null && response.ok;
}
```
  
## TODO:
- Improve documentation
  - Improve readme file
  - Add devtools