import 'package:flutter/material.dart';
import 'package:http_api_example/models/example_photo_model.dart';
import 'package:provider/provider.dart';

import '../api.dart';

class CacheExample extends StatefulWidget {
  @override
  _CacheExampleState createState() => _CacheExampleState();
}

class _CacheExampleState extends State<CacheExample> {
  ExamplePhotoModel _currentPhoto;

  void _fetchPhoto() async {
    final api = Provider.of<Api>(context, listen: false);

    await for (final photo in api.getPhotoWithCache()) {
      if (mounted)
        setState(() {
          _currentPhoto = photo;
        });
    }
  }

  @override
  void didChangeDependencies() {
    if (_currentPhoto == null) _fetchPhoto();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cache example'),
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
