import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/error_messages.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  final Object? error;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final message = friendlyError(error);

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!compact)
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: scheme.error, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.12),
                  blurRadius: 0,
                  offset: const Offset(3, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 38,
              color: scheme.onErrorContainer,
            ),
          )
        else
          Icon(
            Icons.cloud_off_rounded,
            size: 28,
            color: scheme.error,
          ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.xl),
        Text(
          compact ? 'Something went wrong' : 'SOMETHING WENT WRONG',
          style: (compact ? text.titleMedium : text.headlineSmall)?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: compact ? 0 : -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          style: text.bodyMedium,
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try again'),
          ),
        ],
      ],
    );

    if (compact) return body;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: body,
      ),
    );
  }
}
