import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/match.dart';
import '../providers/auth_providers.dart';
import '../providers/match_providers.dart';
import '../theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/floating_icon_button.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/rating_badge.dart';

class SwapsScreen extends ConsumerWidget {
  const SwapsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(myMatchesStreamProvider);
    final me = ref.watch(authStateProvider).value;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: kFloatingHeaderHeight),
              child: matchesAsync.when(
                loading: () => const _SwapsSkeleton(),
                error: (e, _) => AppErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(myMatchesStreamProvider),
                ),
                data: (matches) {
                  if (me == null) return const SizedBox.shrink();
                  if (matches.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.handshake_outlined,
                      title: 'No swaps yet',
                      body:
                          'Head to Discover to find someone to teach and learn with.',
                      action: OutlinedButton.icon(
                        onPressed: () => context.go('/discover'),
                        icon: const Icon(Icons.search_rounded, size: 18),
                        label: const Text('Discover'),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        AppSpacing.lg,
                        AppSpacing.xxl,
                        AppSpacing.xxxl),
                    itemCount: matches.length + 1,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 4, bottom: AppSpacing.sm),
                          child: Text(
                            'YOUR SWAPS',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        );
                      }
                      final m = matches[i - 1];
                      return _MatchTile(match: m, myUid: me.uid);
                    },
                  );
                },
              ),
            ),
            const Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.md,
              child: AppLogo.compact(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchTile extends ConsumerWidget {
  const _MatchTile({required this.match, required this.myUid});

  final Match match;
  final String myUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final otherUid = match.otherUid(myUid);
    final otherAsync = ref.watch(userByIdProvider(otherUid));
    final alias = otherAsync.value?.alias ?? '...';
    final (label, color, icon) = switch (match.state) {
      MatchState.matched => (
          'New swap',
          scheme.tertiary,
          Icons.fiber_new_rounded,
        ),
      MatchState.inProgress => match.didTurn(myUid)
          ? ('Waiting for $alias', scheme.outline,
              Icons.hourglass_empty_rounded)
          : ('Your turn', scheme.primary, Icons.bolt_rounded),
      MatchState.completed => (
          'Complete',
          scheme.secondary,
          Icons.check_circle_rounded,
        ),
    };
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(color: scheme.outline, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        onTap: () => context.go('/match/${match.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Row(
            children: [
              InitialsAvatar(alias: alias, radius: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alias,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppRadii.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 12, color: color),
                              const SizedBox(width: 4),
                              Text(
                                label,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: color,
                                      letterSpacing: 0.2,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: RatingBadge(uid: otherUid, compact: true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwapsSkeleton extends StatelessWidget {
  const _SwapsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.xxxl),
      children: const [
        SkeletonBox(height: 14, width: 100),
        SizedBox(height: AppSpacing.md),
        SkeletonCard(height: 72),
        SizedBox(height: AppSpacing.sm),
        SkeletonCard(height: 72),
        SizedBox(height: AppSpacing.sm),
        SkeletonCard(height: 72),
      ],
    );
  }
}
