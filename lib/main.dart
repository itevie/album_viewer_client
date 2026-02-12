import 'package:album_viewer_client/api.dart';
import 'package:album_viewer_client/base_scaffold.dart';
import 'package:album_viewer_client/image_grid.dart';
import 'package:album_viewer_client/router.dart';
import 'package:album_viewer_client/util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  (() async {
    prefs = await SharedPreferences.getInstance();
  })();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Album Viewer',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),

      themeMode: ThemeMode.dark,
    );
  }
}

class Main extends StatelessWidget {
  const Main({super.key});

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
