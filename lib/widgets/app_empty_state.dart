import 'package:flutter/material.dart';

import '../theme.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Block icon — hard-cornered with offset shadow, matches the
            // overall design language of cards and the bottom dock.
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(color: scheme.onSurface, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.12),
                    blurRadius: 0,
                    offset: const Offset(3, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 38,
                color: scheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title.toUpperCase(),
              style: text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
