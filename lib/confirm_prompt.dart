import 'package:flutter/material.dart';

Future<bool> showConfirmPrompt(
  BuildContext context,
  Widget title,
  Widget content,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: title,
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );

  // showDialog can return null if dismissed by tapping outside
  return result ?? false;
}
