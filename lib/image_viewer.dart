import 'package:album_viewer_client/api.dart';
import 'package:album_viewer_client/base_page.dart';
import 'package:album_viewer_client/card.dart';
import 'package:album_viewer_client/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

class ImageViewer extends StatelessWidget {
  final Photo photo;

  const ImageViewer({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    addViewParam(photo.id);

    Widget details = Column(
      children: [
        Text(
          "Exif Data",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: FutureBuilder(
            future: getExif(photo.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        snapshot.data!.entries
                            .map(
                              (x) => Row(
                                children: [
                                  Text(
                                    "${x.key}: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(x.value.toString()),
                                ],
                              ),
                            )
                            .toList(),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );

    return PopScope(
      onPopInvokedWithResult: (b, a) async {
        removeViewParam();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Photo: ${photo.name}"),
          actions: [
            IconButton(
              onPressed: () {
                downloadFromUrl("${photo.link}${getSmid()}", photo.name);
              },
              tooltip: "Download",
              icon: Icon(Icons.download),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(
                    text:
                        "${Uri.base.origin}${getSmid()}&view=${photo.id}#/all",
                  ),
                );
              },
              tooltip: "Copy Image Link",
              icon: Icon(Icons.link),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(
                    text:
                        "${Uri.base.origin}/images/${photo.id}/view${getSmid()}",
                  ),
                );
              },
              tooltip: "Copy Direct Image Link",
              icon: Icon(Icons.image),
            ),
          ],
        ),
        body: BasePage(
          widget: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 800;

              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Image.network(
                        "${photo.link}${getSmid()}",
                        fit: BoxFit.contain,
                      ),
                    ),
                    MyCard(child: details),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image.network(
                      "${photo.link}${getSmid()}",
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 400, child: MyCard(child: details)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

void removeViewParam() {
  final uri = Uri.base;
  final newParams = Map<String, String>.from(uri.queryParameters)
    ..remove('view');
  final newUri = uri.replace(queryParameters: newParams);

  web.window.history.replaceState(null, '', newUri.toString());
}

void addViewParam(int id) {
  final uri = Uri.base;
  final newParams = Map<String, String>.from(uri.queryParameters);
  newParams['view'] = id.toString();
  final newUri = uri.replace(queryParameters: newParams);

  web.window.history.replaceState(null, '', newUri.toString());
}
