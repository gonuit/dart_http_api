import 'package:flutter/material.dart';
import 'package:http_api_example/models/example_photo_model.dart';
import 'package:provider/provider.dart';

import '../api.dart';

class BasicExample extends StatefulWidget {
  @override
  _BasicExampleState createState() => _BasicExampleState();
}

class _BasicExampleState extends State<BasicExample> {
  ExamplePhotoModel _currentPhoto;

  void _fetchPhoto() async {
    final api = Provider.of<Api>(context, listen: false);

    final photo = await api.getRandomPhoto();

    setState(() {
      _currentPhoto = photo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('basic example'),
      ),
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
            if (_currentPhoto != null) const SizedBox(height: 15),
            if (_currentPhoto != null) Text("Author: ${_currentPhoto.author}"),
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
