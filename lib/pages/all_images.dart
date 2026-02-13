import 'package:album_viewer_client/api.dart';
import 'package:album_viewer_client/util/base_scaffold.dart';
import 'package:album_viewer_client/util/image_grid.dart';
import 'package:flutter/material.dart';

class AllImages extends StatelessWidget {
  const AllImages({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: FutureBuilder(
          future: fetchPhotos(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            } else {
              return ImageGrid(photos: snapshot.data ?? []);
            }
          },
        ),
      ),
    );
  }
}
