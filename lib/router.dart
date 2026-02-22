import 'package:album_viewer_client/pages/images_viewer.dart';
import 'package:album_viewer_client/pages/settings.dart';
import 'package:album_viewer_client/pages/tag_viewer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/all',
      builder: (_, state) {
        final view = Uri.base.queryParameters['view'];
        return ImagesViewer(view: view != null ? int.tryParse(view) : null);
      },
    ),
    GoRoute(path: '/', builder: (_, __) => TagViewer()),
    GoRoute(path: '/settings', builder: (_, __) => SettingsPage()),
    GoRoute(
      path: '/tags/:name',
      builder: (context, state) {
        final name = state.pathParameters['name'];
        final view = Uri.base.queryParameters['view'];
        return ImagesViewer(
          tag: name,
          view: view != null ? int.tryParse(view) : null,
        );
      },
    ),
    GoRoute(
      path: '/subtags/:name',
      builder: (context, state) {
        final name = state.pathParameters['name'];
        return TagViewer(baseSubTag: name);
      },
    ),

    // GoRoute(path: '/settings', builder: (_,HomePage __) => const SettingsPage()),
  ],
);

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("hi")));
  }
}
