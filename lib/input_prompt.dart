import 'package:flutter/material.dart';

Future<String?> showInputPrompt(
  BuildContext context,
  Widget title,
  Widget? notes,
) async {
  String input = "";

  final result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: title,
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 150, maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notes != null) ...[notes, const SizedBox(height: 8)],
              TextField(
                autofocus: true,
                onChanged: (value) {
                  input = value;
                },
                decoration: const InputDecoration(
                  hintText: "Type here...",
                  isDense: true, // Makes the TextField shorter
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(input),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );

  return result;
}
