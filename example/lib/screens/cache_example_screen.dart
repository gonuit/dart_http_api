import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api.dart';
import '../models/example_photo_model.dart';

class CacheExample extends StatefulWidget {
  @override
  _CacheExampleState createState() => _CacheExampleState();
}

class _CacheExampleState extends State<CacheExample> {
  ExamplePhotoModel? _currentPhoto;

  void _fetchPhoto() async {
    final api = Provider.of<Api>(context, listen: false);

    await for (final photo in api.getPhotoWithCache()) {
      if (mounted) {
        setState(() {
          _currentPhoto = photo;
        });
      }
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
                      _currentPhoto!.downloadUrl,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            if (_currentPhoto != null) const SizedBox(height: 15),
            if (_currentPhoto != null) Text("Author: ${_currentPhoto!.author}"),
            const SizedBox(height: 15),
            ElevatedButton(
              child: const Text("Fetch photo"),
              onPressed: _fetchPhoto,
            ),
          ],
        ),
      ),
    );
  }
}
