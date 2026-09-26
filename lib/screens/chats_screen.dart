import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/match.dart';
import '../providers/auth_providers.dart';
import '../providers/chat_providers.dart';
import '../providers/match_providers.dart';
import '../theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/floating_icon_button.dart';
import '../widgets/initials_avatar.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

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
                loading: () => const _ChatsSkeleton(),
                error: (e, _) => AppErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(myMatchesStreamProvider),
                ),
                data: (matches) {
                  if (me == null) return const SizedBox.shrink();
                  if (matches.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'No conversations yet',
                      body: 'Match with someone in Discover to start a chat.',
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
                            'CHATS',
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
                      return _ChatTile(match: m, myUid: me.uid);
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

class _ChatTile extends ConsumerWidget {
  const _ChatTile({required this.match, required this.myUid});

  final Match match;
  final String myUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final otherUid = match.otherUid(myUid);
    final otherAsync = ref.watch(userByIdProvider(otherUid));
    final alias = otherAsync.value?.alias ?? '...';
    final lastAsync = ref.watch(lastMessageProvider(match.id));
    final last = lastAsync.value;

    final preview = last == null
        ? 'Say hi to start the swap'
        : (last.senderUid == myUid ? 'You: ${last.text}' : last.text);
    final ts = last?.createdAt;
    final tsLabel = ts == null ? '' : _relativeTime(ts);

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(color: scheme.outline, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        onTap: () => context.go('/match/${match.id}/chat'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InitialsAvatar(alias: alias, radius: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alias,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (tsLabel.isNotEmpty)
                          Text(
                            tsLabel,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _relativeTime(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inSeconds < 60) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${(diff.inDays / 7).floor()}w';
}

class _ChatsSkeleton extends StatelessWidget {
  const _ChatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.xxxl),
      children: const [
        SkeletonBox(height: 14, width: 60),
        SizedBox(height: AppSpacing.md),
        SkeletonCard(height: 78),
        SizedBox(height: AppSpacing.sm),
        SkeletonCard(height: 78),
        SizedBox(height: AppSpacing.sm),
        SkeletonCard(height: 78),
      ],
    );
  }
}
