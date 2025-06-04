import 'package:flutter/material.dart';
import 'package:http_api/http_api.dart';
import 'package:provider/provider.dart';

import 'api.dart';
import 'screens/basic_example_screen.dart';
import 'screens/cache_example_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => Api(
        /// Provide base url for your api
        url: Uri.parse("https://picsum.photos"),

        /// Assign middleware by providing ApiLinks (to provide more than one middleware, chain them)
        link: LoggerLink(responseDuration: true, endpoint: true)
            .chain(HttpLink()),
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
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed("basic"),
                child: Text("Basic example"),
              ),
              ElevatedButton(
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
