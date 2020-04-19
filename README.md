# http_api
  
[![Codemagic build status](https://api.codemagic.io/apps/5e9c9c7a7af7f3ae2a99d6a0/5e9c9c7a7af7f3ae2a99d69f/status_badge.svg)](https://codemagic.io/apps/5e9c9c7a7af7f3ae2a99d6a0/5e9c9c7a7af7f3ae2a99d69f/latest_build)
![Pub Version](https://img.shields.io/pub/v/http_api?color=%230175c2)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
  
Simple yet powerful wrapper around http package inspired by apollo graphql links. This package provides you a simple way of adding middlewares to your app http requests.

## IMPORTANT
This library is under development, breaking API changes might still happen. If you would like to make use of this library please make sure to provide which version you want to use e.g:
```yaml
dependencies:
  http_api: 0.3.0
```

## Getting Started

### 1. First create your Api class by extending `BaseApi` class
```dart
// define your api class
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

  /// Implement api request methods 
  Future<ExamplePhotoModel> getRandomPhoto() async {

    /// Use [send] method to make api request
    final response = await send(ApiRequest(
      endpoint: "/id/${Random().nextInt(50)}/info",
      method: HttpMethod.get,
    ));

    /// Parse http response
    return ExamplePhotoModel.fromJson(json.decode(response.body));
  }
}

```

#### TIP: You can provide your Api instance down the widget tree using [provider](https://pub.dev/packages/provider) package.
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Provider(
        create: (_) => Api(
          /// Provide base url for your api
          url: Uri.parse("https://picsum.photos"),
          /// Assign middleware by providing ApiLinks (to provide more than one middleware, chain them)
          link: HeadersMapperLink(["authorization"])
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

### 2. Make api request
```dart
class _ApiExampleScreenState extends State<ApiExampleScreen> {

  void _fetchPhoto() async {
    final api = Provider.of<Api>(context, listen: false);
    ExamplePhotoModel photo = await api.getRandomPhoto();
    // Do sth with response
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          child: const Text("Fetch photo"),
          onPressed: _fetchPhoto,
        ),
      ),
    );
  }

}
```

## TODO:
- Unit tests
- Caching based on [ApiRequest]
- Improve readme (provide more examples)
- Simple graphQL client (without subscriptions support)