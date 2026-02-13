import 'package:album_viewer_client/api.dart';
import 'package:flutter/material.dart';

class FullscreenImage extends StatelessWidget {
  final Photo photo;

  const FullscreenImage({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.network("${photo.link}${getSmid()}")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
    );
  }
}
