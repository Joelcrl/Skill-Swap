import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/rating_providers.dart';
import '../theme.dart';

class RatingBadge extends ConsumerWidget {
  const RatingBadge({
    super.key,
    required this.uid,
    this.compact = false,
  });

  final String uid;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aggAsync = ref.watch(userRatingAggregateProvider(uid));
    return aggAsync.when(
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (agg) {
        if (agg.count == 0) {
          return Text(
            'No ratings yet',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          );
        }
        final avgText = agg.average.toStringAsFixed(1);
        final iconSize = compact ? 14.0 : 18.0;
        final textStyle = compact
            ? Theme.of(context).textTheme.bodySmall
            : Theme.of(context).textTheme.bodyMedium;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded,
                color: AppColors.amber500, size: iconSize),
            const SizedBox(width: 4),
            Text('$avgText  (${agg.count})', style: textStyle),
          ],
        );
      },
    );
  }
}
