import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/user_profile.dart';
import '../providers/auth_providers.dart';
import '../providers/profile_providers.dart';
import '../theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/floating_icon_button.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/rating_badge.dart';
import '../widgets/swap_chips.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: kFloatingHeaderHeight),
              child: profileAsync.when(
                loading: () => const _MeSkeleton(),
                error: (e, _) => AppErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(currentProfileProvider),
                ),
                data: (profile) {
                  if (profile == null) {
                    return const AppEmptyState(
                      icon: Icons.person_off_outlined,
                      title: 'No profile',
                      body:
                          "We couldn't load your profile. Try signing out and back in.",
                    );
                  }
                  return _MeBody(profile: profile);
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

class _MeBody extends ConsumerWidget {
  const _MeBody({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi,',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.alias,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        RatingBadge(uid: profile.uid),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  InitialsAvatar(alias: profile.alias, radius: 36),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              _BarterCard(profile: profile),
              const SizedBox(height: AppSpacing.xxl),
              _MeAction(
                icon: Icons.edit_outlined,
                label: 'Edit profile',
                onTap: () => context.go('/profile-edit'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _MeAction(
                icon: Icons.tune_rounded,
                label: 'Settings',
                onTap: () => context.go('/settings'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _MeAction(
                icon: Icons.logout_rounded,
                label: 'Sign out',
                destructive: true,
                onTap: () async {
                  HapticFeedback.selectionClick();
                  await ref.read(authServiceProvider).signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarterCard extends StatelessWidget {
  const _BarterCard({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(color: scheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Your barter',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/profile-edit'),
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SwapChips(
            offered: List<String>.from(profile.skillsOffered),
            wanted: List<String>.from(profile.skillsWanted),
            offeredLabel: 'YOU TEACH',
            wantedLabel: 'YOU WANT TO LEARN',
            emptyOfferedHint: 'Add skills you can teach',
            emptyWantedHint: 'Add skills you want to learn',
          ),
        ],
      ),
    );
  }
}

class _MeAction extends StatelessWidget {
  const _MeAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = destructive ? scheme.error : scheme.onSurface;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(color: scheme.outline, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, color: fg, size: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: fg,
                        fontWeight: destructive
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
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

class _MeSkeleton extends StatelessWidget {
  const _MeSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.xxxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(height: 14, width: 30),
                        SizedBox(height: 6),
                        SkeletonBox(height: 28, width: 160),
                        SizedBox(height: 6),
                        SkeletonBox(height: 14, width: 100),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),
                  SkeletonAvatar(radius: 36),
                ],
              ),
              SizedBox(height: AppSpacing.xxl),
              SkeletonCard(height: 220),
            ],
          ),
        ),
      ),
    );
  }
}
