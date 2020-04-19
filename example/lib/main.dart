import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http_api/http_api.dart';
import 'package:provider/provider.dart';

import 'models/example_photo_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => Api(
        /// Provide base url for your api
        url: Uri.parse("https://picsum.photos"),

        /// Assign middleware by providing ApiLinks (to provide more than one middleware, chain them)
        link: DebugLink(responseDuration: true, url: true).chain(HttpLink()),
      ),
      child: MaterialApp(
        title: 'http_api example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ExamplePhotoModel _currentPhoto;

  void _fetchPhoto() async {
    final api = Provider.of<Api>(context, listen: false);
    ExamplePhotoModel photo = await api.getRandomPhoto();

    setState(() {
      _currentPhoto = photo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              height: 300,
              color: Colors.black12,
              child: _currentPhoto != null
                  ? Image.network(
                      _currentPhoto.downloadUrl,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            const SizedBox(height: 15),
            RaisedButton(
              child: const Text("Fetch photo"),
              onPressed: _fetchPhoto,
            ),
          ],
        ),
      ),
    );
  }
}
