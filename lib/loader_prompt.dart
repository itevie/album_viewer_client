import 'package:flutter/material.dart';

Future<T> showLoadingPrompt<T>(
  BuildContext context,
  Future<T> future, {
  Widget? title,
  Widget? message,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          title: title,
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Flexible(child: message ?? const Text("Loading…")),
            ],
          ),
        ),
      );
    },
  );

  try {
    final result = await future;

    // ignore: use_build_context_synchronously
    Navigator.of(context, rootNavigator: true).pop();

    return result;
  } catch (e) {
    // ignore: use_build_context_synchronously
    Navigator.of(context, rootNavigator: true).pop();
    rethrow;
  }
}
