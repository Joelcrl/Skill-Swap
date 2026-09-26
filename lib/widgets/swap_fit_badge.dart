import 'package:flutter/material.dart';

import '../theme.dart';

class SwapFitBadge extends StatelessWidget {
  const SwapFitBadge({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final v = value.clamp(0, 100);

    // Bold three-tier color logic. High = sunburst (CTA pop), mid = terracotta
    // primary, low = muted. Hard corners + heavy number for editorial feel.
    final Color fg;
    final Color bg;
    final Color edge;
    if (v >= 67) {
      fg = Colors.white;
      bg = AppColors.sunburst500;
      edge = AppColors.sunburst700;
    } else if (v >= 33) {
      fg = scheme.onPrimary;
      bg = scheme.primary;
      edge = AppColors.terracotta700;
    } else {
      fg = scheme.onSurfaceVariant;
      bg = scheme.surfaceContainerHigh;
      edge = scheme.outline;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadii.md),
          topRight: Radius.circular(AppRadii.md),
          bottomLeft: Radius.circular(AppRadii.md),
          bottomRight: Radius.circular(4),
        ),
        border: Border.all(color: edge, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: edge.withValues(alpha: 0.25),
            blurRadius: 0,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$v',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                      letterSpacing: -1.5,
                    ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 1),
                child: Text(
                  '%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'SWAP FIT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  height: 1.0,
                ),
          ),
        ],
      ),
    );
  }
}
