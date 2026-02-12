import 'package:flutter/material.dart';

Future<void> showMessagePrompt(
  BuildContext context,
  Widget title,
  Widget content, {
  List<Widget>? extraButtons,
}) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: title,
        content: content,
        actions: [
          ...(extraButtons ?? []),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
