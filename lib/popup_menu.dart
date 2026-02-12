import 'package:flutter/material.dart';

typedef PopupMenuItemC = ({String name, IconData icon, VoidCallback callback});

class PopupMenu extends StatelessWidget {
  final List<PopupMenuItemC> items;
  final Widget? child;

  const PopupMenu({super.key, required this.items, this.child});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        final item = items.firstWhere((x) => x.name == value);
        item.callback();
      },
      itemBuilder:
          (context) =>
              items
                  .map(
                    (item) => PopupMenuItem(
                      value: item.name,
                      child: Row(
                        children: [
                          Icon(item.icon),
                          SizedBox(width: 8),
                          Text(item.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
      tooltip: '',
      child: child ?? const Icon(Icons.more_vert),
    );
  }
}
