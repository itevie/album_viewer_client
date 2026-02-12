import 'package:album_viewer_client/base_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final Widget? fab;

  const BaseScaffold({super.key, required this.body, this.fab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Album Viewer'),

        actions: [
          TextButton(
            onPressed: () {
              context.go("/");
            },
            child: const Text("Home"),
          ),
          TextButton(
            onPressed: () {
              context.go("/all");
            },
            child: const Text("All"),
          ),
          TextButton(
            onPressed: () {
              context.go("/settings");
            },
            child: const Text("Settings"),
          ),
          const SizedBox(width: 8),
        ],
      ),

      floatingActionButton: fab,

      body: BasePage(widget: body),
    );
  }
}
