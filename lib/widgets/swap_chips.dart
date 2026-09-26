import 'package:flutter/material.dart';

import '../theme.dart';

/// A two-row "I teach / I want" visual used on profile cards, home, and
/// match detail. Communicates the bartering theme more directly than a
/// generic icon-and-chips card.
class SwapChips extends StatelessWidget {
  const SwapChips({
    super.key,
    required this.offered,
    required this.wanted,
    this.offeredLabel = 'TEACHES',
    this.wantedLabel = 'WANTS TO LEARN',
    this.dense = false,
    this.emptyOfferedHint = 'Nothing yet',
    this.emptyWantedHint = 'Nothing yet',
  });

  final List<String> offered;
  final List<String> wanted;
  final String offeredLabel;
  final String wantedLabel;
  final bool dense;
  final String emptyOfferedHint;
  final String emptyWantedHint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChipRow(
          label: offeredLabel,
          tint: scheme.primary,
          tags: offered,
          dense: dense,
          emptyHint: emptyOfferedHint,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: dense ? 8 : 12),
          child: _SwapDivider(),
        ),
        _ChipRow(
          label: wantedLabel,
          tint: scheme.secondary,
          tags: wanted,
          dense: dense,
          emptyHint: emptyWantedHint,
        ),
      ],
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.label,
    required this.tint,
    required this.tags,
    required this.dense,
    required this.emptyHint,
  });

  final String label;
  final Color tint;
  final List<String> tags;
  final bool dense;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: tint,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                    color: tint,
                  ),
            ),
          ],
        ),
        SizedBox(height: dense ? AppSpacing.xs : AppSpacing.sm),
        if (tags.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(emptyHint,
                style: Theme.of(context).textTheme.bodySmall),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags
                  .map((t) => _SkillChip(label: t, tint: tint, dense: dense))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({
    required this.label,
    required this.tint,
    required this.dense,
  });

  final String label;
  final Color tint;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 9 : 11,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(color: tint.withValues(alpha: 0.30), width: 1),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.onSurface,
              letterSpacing: 0.1,
            ),
      ),
    );
  }
}

class _SwapDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: scheme.outlineVariant),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            '⇄',
            style: TextStyle(
              fontSize: 18,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: scheme.outlineVariant),
        ),
      ],
    );
  }
}
