import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/web.dart' as web;

late SharedPreferences prefs;

void navigate(BuildContext context, Widget widget) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => widget));
}

String? getPassword() {
  return prefs.getString("password");
}

String niceFormat(String string) {
  return string
      .split(" ")
      .map((x) => x[0].toUpperCase() + x.substring(1))
      .join(" ");
}

void downloadFromUrl(String url, String filename) {
  final anchor =
      web.HTMLAnchorElement()
        ..href = url
        ..download = filename;

  anchor.click();
}

@JS('location.reload')
external void reloadPage();
