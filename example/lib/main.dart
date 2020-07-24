import 'package:flutter/material.dart';
import 'package:http_api/http_api.dart';
import 'package:http_api_example/api.dart';
import 'package:http_api_example/screens/basic_example_screen.dart';
import 'package:http_api_example/screens/cache_example_screen.dart';
import 'package:provider/provider.dart';

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
        initialRoute: "home",
        routes: {
          "basic": (_) => BasicExample(),
          "cache": (_) => CacheExample(),
          "home": (_) => HomeScreen(),
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('http_api examples'),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ListView(
            padding: EdgeInsets.all(15),
            children: <Widget>[
              RaisedButton(
                onPressed: () => Navigator.of(context).pushNamed("basic"),
                child: Text("Basic example"),
              ),
              RaisedButton(
                onPressed: () => Navigator.of(context).pushNamed("cache"),
                child: Text("Cache example"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
