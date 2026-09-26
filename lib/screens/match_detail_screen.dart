import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/match.dart';
import '../models/rating.dart';
import '../models/user_profile.dart';
import '../providers/auth_providers.dart';
import '../providers/match_providers.dart';
import '../providers/rating_providers.dart';
import '../theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/floating_icon_button.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/match_journey.dart';
import '../widgets/rating_badge.dart';
import '../widgets/swap_chips.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  bool _submitting = false;

  Future<void> _markTurnDone(String myUid) async {
    HapticFeedback.mediumImpact();
    setState(() => _submitting = true);
    try {
      await ref.read(matchServiceProvider).markMyTurnComplete(
            matchId: widget.matchId,
            myUid: myUid,
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _openRateSheet({
    required String myUid,
    required String ratedUid,
    required String ratedAlias,
  }) async {
    HapticFeedback.selectionClick();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RateSheet(
        matchId: widget.matchId,
        raterUid: myUid,
        ratedUid: ratedUid,
        ratedAlias: ratedAlias,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(matchByIdProvider(widget.matchId));
    final me = ref.watch(authStateProvider).value;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: kFloatingHeaderHeight),
              child: matchAsync.when(
                loading: () => const _MatchDetailSkeleton(),
                error: (e, _) => AppErrorView(
                  error: e,
                  onRetry: () =>
                      ref.invalidate(matchByIdProvider(widget.matchId)),
                ),
                data: (match) {
                  if (me == null) return const SizedBox.shrink();
                  if (match == null) {
                    return const AppEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Swap not found',
                      body:
                          'This swap may have been removed. Head back and try another.',
                    );
                  }
                  if (!match.isMember(me.uid)) {
                    return const AppEmptyState(
                      icon: Icons.lock_outline,
                      title: 'Not your swap',
                      body: 'You are not part of this swap.',
                    );
                  }
                  final otherUid = match.otherUid(me.uid);
                  final otherAsync = ref.watch(userByIdProvider(otherUid));
                  return otherAsync.when(
                    loading: () => const _MatchDetailSkeleton(),
                    error: (e, _) => AppErrorView(
                      error: e,
                      onRetry: () =>
                          ref.invalidate(userByIdProvider(otherUid)),
                    ),
                    data: (other) {
                      final myRatingAsync = ref.watch(myRatingForMatchProvider(
                        MyRatingArgs(
                            matchId: widget.matchId, raterUid: me.uid),
                      ));
                      return _MatchBody(
                        match: match,
                        myUid: me.uid,
                        other: other,
                        submitting: _submitting,
                        onMarkDone: () => _markTurnDone(me.uid),
                        myRating: myRatingAsync.value,
                        onRate: other == null
                            ? null
                            : () => _openRateSheet(
                                  myUid: me.uid,
                                  ratedUid: other.uid,
                                  ratedAlias: other.alias,
                                ),
                      );
                    },
                  );
                },
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.md,
              child: FloatingIconButton(
                icon: kBackIcon,
                tooltip: 'Back',
                onPressed: () => context.go('/swaps'),
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.md,
              child: Row(
                children: [
                  FloatingIconButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    tooltip: 'Chat',
                    onPressed: () =>
                        context.go('/match/${widget.matchId}/chat'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FloatingIconButton(
                    icon: kRefreshIcon,
                    tooltip: 'Refresh',
                    onPressed: () =>
                        ref.invalidate(matchByIdProvider(widget.matchId)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchBody extends StatelessWidget {
  const _MatchBody({
    required this.match,
    required this.myUid,
    required this.other,
    required this.submitting,
    required this.onMarkDone,
    required this.myRating,
    required this.onRate,
  });

  final Match match;
  final String myUid;
  final UserProfile? other;
  final bool submitting;
  final VoidCallback onMarkDone;
  final Rating? myRating;
  final VoidCallback? onRate;

  @override
  Widget build(BuildContext context) {
    final myDone = match.didTurn(myUid);
    final isComplete = match.state == MatchState.completed;
    final alias = other?.alias ?? '...';
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.xxxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Editorial hero — avatar + alias + state badge in one block.
              Center(
                child: Column(
                  children: [
                    InitialsAvatar(alias: alias, radius: 48),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      alias,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    if (other != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      RatingBadge(uid: other!.uid),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    _StateBadge(state: match.state),
                    if (match.roundNumber > 1) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Round ${match.roundNumber}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Visual exchange — block-styled barter card for the OTHER person.
              if (other != null) ...[
                Container(
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
                  child: SwapChips(
                    offered: other!.skillsOffered,
                    wanted: other!.skillsWanted,
                    offeredLabel: '$alias TEACHES'.toUpperCase(),
                    wantedLabel: '$alias WANTS'.toUpperCase(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Full journey timeline — matched → you → them → done → rated.
              MatchJourney(
                match: match,
                myUid: myUid,
                myHasRated: myRating != null,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _statusLine(match: match, myUid: myUid, otherAlias: alias),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Action: mark turn / rate.
              if (!isComplete)
                _PrimaryAction(
                  icon: myDone
                      ? Icons.check_circle_rounded
                      : Icons.check_circle_outline_rounded,
                  label: myDone
                      ? 'You marked your turn done'
                      : 'I taught my turn',
                  onPressed: (myDone || submitting) ? null : onMarkDone,
                  loading: submitting,
                ),
              if (isComplete) ...[
                _CompletedBanner(),
                const SizedBox(height: AppSpacing.md),
                _PrimaryAction(
                  icon: myRating != null
                      ? Icons.check_circle
                      : Icons.star_rate_rounded,
                  label: myRating != null
                      ? 'You rated $alias ${myRating!.stars}★'
                      : 'Rate $alias',
                  onPressed: myRating != null ? null : onRate,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.state});
  final MatchState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (state) {
      MatchState.matched => ('NEW MATCH', scheme.tertiary),
      MatchState.inProgress => ('IN PROGRESS', scheme.primary),
      MatchState.completed => ('COMPLETE', scheme.secondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

String _statusLine({
  required Match match,
  required String myUid,
  required String otherAlias,
}) {
  final myDone = match.didTurn(myUid);
  final otherDone = match.turnsCompleted.any((u) => u != myUid);
  if (match.state == MatchState.completed) {
    return 'Both turns complete. Time to rate each other.';
  }
  if (myDone && !otherDone) {
    return 'You taught. Waiting on $otherAlias to teach back.';
  }
  if (!myDone && otherDone) {
    return '$otherAlias taught. Your turn next.';
  }
  return 'Coordinate, teach each other, then mark your turn done.';
}

class _CompletedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.sunburst100,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.sunburst700, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.sunburst700.withValues(alpha: 0.18),
            blurRadius: 0,
            offset: const Offset(3, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.sunburst500,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.sunburst700, width: 1.5),
            ),
            child: const Icon(Icons.celebration_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SWAP COMPLETE!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.sunburst900,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'You both taught each other. Leave a rating.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.sunburst900.withValues(alpha: 0.85),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, size: 20),
        label: Text(label),
      ),
    );
  }
}

// ============================================================
// Rating sheet — full-bleed, dramatic, big stars + label preview.
// ============================================================

class _RateSheet extends ConsumerStatefulWidget {
  const _RateSheet({
    required this.matchId,
    required this.raterUid,
    required this.ratedUid,
    required this.ratedAlias,
  });

  final String matchId;
  final String raterUid;
  final String ratedUid;
  final String ratedAlias;

  @override
  ConsumerState<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends ConsumerState<_RateSheet> {
  int _stars = 0;
  final _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _noteController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars < 1 || _submitting) return;
    HapticFeedback.mediumImpact();
    setState(() => _submitting = true);
    try {
      await ref.read(ratingServiceProvider).submitRating(
            matchId: widget.matchId,
            raterUid: widget.raterUid,
            ratedUid: widget.ratedUid,
            stars: _stars,
            note: _noteController.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _label() {
    return switch (_stars) {
      0 => 'Tap a star to rate',
      1 => 'Bad swap',
      2 => 'Could be better',
      3 => 'Decent',
      4 => 'Great teacher',
      _ => 'Outstanding!',
    };
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final scheme = Theme.of(context).colorScheme;
    final noteLength = _noteController.text.length;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.xxl),
        ),
        border: Border(
          top: BorderSide(color: scheme.outline, width: 1),
          left: BorderSide(color: scheme.outline, width: 1),
          right: BorderSide(color: scheme.outline, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xl + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Hero
          Center(
            child: Column(
              children: [
                InitialsAvatar(alias: widget.ratedAlias, radius: 32),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'How was ${widget.ratedAlias}?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Your rating helps build trust on Skill Swap.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Big stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              final filled = i < _stars;
              return _BigStar(
                filled: filled,
                onTap: _submitting
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        setState(() => _stars = starIndex);
                      },
              );
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          // Label preview with subtle animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Center(
              key: ValueKey(_stars),
              child: Text(
                _label(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _stars > 0
                          ? AppColors.amber500
                          : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Note
          TextField(
            controller: _noteController,
            maxLength: 500,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Add a note (optional)',
              hintText: 'What did they teach? How was it?',
              counterText: '$noteLength / 500',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: (_stars < 1 || _submitting) ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sunburst500,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    scheme.onSurface.withValues(alpha: 0.08),
                disabledForegroundColor:
                    scheme.onSurface.withValues(alpha: 0.38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  side: BorderSide(
                    color: _stars < 1
                        ? Colors.transparent
                        : AppColors.sunburst700,
                    width: 1.5,
                  ),
                ),
              ),
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: const Text('Submit rating'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigStar extends StatelessWidget {
  const _BigStar({required this.filled, required this.onTap});

  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          scale: filled ? 1.08 : 1.0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              key: ValueKey(filled),
              size: 48,
              color: filled ? AppColors.amber500 : scheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchDetailSkeleton extends StatelessWidget {
  const _MatchDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: const [
              SkeletonAvatar(radius: 48),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(height: 28, width: 160),
              SizedBox(height: AppSpacing.xs),
              SkeletonBox(height: 14, width: 100),
              SizedBox(height: AppSpacing.xxl),
              SkeletonCard(height: 200),
              SizedBox(height: AppSpacing.xl),
              SkeletonCard(height: 180),
            ],
          ),
        ),
      ),
    );
  }
}
