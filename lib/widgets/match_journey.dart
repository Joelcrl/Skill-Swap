import 'package:flutter/material.dart';

import '../models/match.dart';
import '../theme.dart';

enum _CellState { done, current, pending }

class MatchJourney extends StatelessWidget {
  const MatchJourney({
    super.key,
    required this.match,
    required this.myUid,
    required this.myHasRated,
  });

  final Match match;
  final String myUid;
  final bool myHasRated;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final myDone = match.didTurn(myUid);
    final otherDone = match.turnsCompleted.any((u) => u != myUid);
    final isInProgress = match.state == MatchState.matched ||
        match.state == MatchState.inProgress;
    final isComplete = match.state == MatchState.completed;

    final cells = <_JourneyCell>[
      const _JourneyCell(label: 'MATCHED', state: _CellState.done),
      _JourneyCell(
        label: 'YOU',
        state: myDone
            ? _CellState.done
            : (isInProgress ? _CellState.current : _CellState.pending),
      ),
      _JourneyCell(
        label: 'THEM',
        state: otherDone
            ? _CellState.done
            : (isInProgress ? _CellState.current : _CellState.pending),
      ),
      _JourneyCell(
        label: 'DONE',
        state: isComplete ? _CellState.done : _CellState.pending,
      ),
      _JourneyCell(
        label: 'RATED',
        state: myHasRated
            ? _CellState.done
            : (isComplete ? _CellState.current : _CellState.pending),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(color: scheme.onSurface, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 0,
            offset: const Offset(3, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR JOURNEY',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < cells.length; i++) ...[
                Expanded(child: cells[i]),
                if (i < cells.length - 1)
                  _Connector(active: cells[i].state == _CellState.done),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _JourneyCell extends StatelessWidget {
  const _JourneyCell({required this.label, required this.state});

  final String label;
  final _CellState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, icon) = switch (state) {
      _CellState.done => (
          scheme.primary,
          scheme.onPrimary,
          Icons.check_rounded,
        ),
      _CellState.current => (
          scheme.primary.withValues(alpha: 0.18),
          scheme.primary,
          Icons.circle,
        ),
      _CellState.pending => (
          scheme.surfaceContainerHigh,
          scheme.outline,
          null,
        ),
    };
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: state == _CellState.current
                ? Border.all(color: scheme.primary, width: 2)
                : null,
          ),
          child: icon == null
              ? null
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Icon(
                    icon,
                    key: ValueKey('${state.name}_$icon'),
                    color: fg,
                    size: state == _CellState.current ? 10 : 20,
                  ),
                ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.2,
                fontWeight: state == _CellState.pending
                    ? FontWeight.w500
                    : FontWeight.w700,
                color: state == _CellState.pending
                    ? scheme.onSurfaceVariant
                    : scheme.onSurface,
              ),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        height: 2,
        width: 16,
        color: active ? scheme.primary : scheme.outlineVariant,
      ),
    );
  }
}
