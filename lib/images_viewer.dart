// ignore: unused_import
import "dart:io";
import 'package:album_viewer_client/api.dart';
import 'package:album_viewer_client/base_scaffold.dart';
import 'package:album_viewer_client/image_grid.dart';
import 'package:album_viewer_client/util.dart';
import 'package:dawn_ui_flutter/prompts/prompts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImagesViewer extends StatelessWidget {
  final String? tag;
  final int? view;

  const ImagesViewer({super.key, this.tag, this.view});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      fab:
          getPassword() != null
              ? FloatingActionButton(
                onPressed: () async {
                  final values = await pickFiles();

                  if (values == null || values.isEmpty) return;

                  // ignore: use_build_context_synchronously
                  final result = await showLoadingPrompt(
                    // ignore: use_build_context_synchronously
                    context,
                    uploadFiles(values),
                  );

                  if (result != null) {
                    // ignore: use_build_context_synchronously
                    showMessagePrompt(context, Text("Error"), Text(result));
                    return;
                  }

                  showMessagePrompt(
                    // ignore: use_build_context_synchronously
                    context,
                    Text("Uploaded!"),
                    Text("${values.length} images were uploaded"),
                  );

                  Future.delayed(Duration(seconds: 1), () {
                    reloadPage();
                  });
                },
                child: Icon(Icons.add),
              )
              : null,
      body: Center(
        child: FutureBuilder(
          future: tag != null ? fetchPhotosByTag(tag!) : fetchPhotos(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            } else {
              return ImageGrid(photos: snapshot.data ?? [], view: view);
            }
          },
        ),
      ),
    );
  }
}

Future<List<PlatformFile>?> pickFiles() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.image,
  );

  if (result != null) {
    return result.files;
  }
  return null;
}

Future<String?> uploadFiles(List<PlatformFile> files) async {
  var uri = Uri.parse('$baseUrl/upload');
  var request = http.MultipartRequest('POST', uri);
  request.headers['Admin-Session'] = getPassword() ?? "";

  for (var file in files) {
    if (file.path != null) {
      request.files.add(
        http.MultipartFile.fromBytes('files', file.bytes!, filename: file.name),
      );
    }
  }

  var response = await request.send();

  if (response.statusCode == 200) {
    return null;
  } else {
    return "Failed to upload files: ${response.statusCode}";
  }
}
