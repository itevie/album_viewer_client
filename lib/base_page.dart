import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final Widget widget;

  const BasePage({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(10), child: widget);
  }
}
