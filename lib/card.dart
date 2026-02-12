import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final Widget child;
  final bool danger;
  final VoidCallback? onTap;

  const MyCard({
    super.key,
    required this.child,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor:
          onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color:
            danger
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          hoverColor: theme.colorScheme.primary.withOpacity(0.08),
          splashColor: theme.colorScheme.primary.withOpacity(0.15),
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}
