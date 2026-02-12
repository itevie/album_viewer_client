import 'package:flutter/material.dart';

Future<int?> showSelectPrompt(
  BuildContext context,
  Widget title,
  Map<int, String> options, {
  Widget? notes,
  int? initialValue,
}) async {
  int? selected = initialValue;

  final result = await showDialog<int>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: title,
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150, maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notes != null) ...[notes, const SizedBox(height: 8)],
                  DropdownButtonFormField<int>(
                    value: selected,
                    isDense: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    items:
                        options.entries
                            .map(
                              (e) => DropdownMenuItem<int>(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        selected = value;
                      });
                    },
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
                onPressed:
                    selected == null
                        ? null
                        : () => Navigator.of(context).pop(selected),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    },
  );

  return result;
}
