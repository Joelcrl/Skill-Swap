import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/message.dart';
import '../providers/auth_providers.dart';
import '../providers/chat_providers.dart';
import '../providers/match_providers.dart';
import '../theme.dart';
import '../utils/error_messages.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/floating_icon_button.dart';
import '../widgets/initials_avatar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send(String myUid) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    HapticFeedback.lightImpact();
    setState(() => _sending = true);
    try {
      await ref.read(chatServiceProvider).sendMessage(
            matchId: widget.matchId,
            senderUid: myUid,
            text: text,
          );
      _controller.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send. ${friendlyError(e)}')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(authStateProvider).value;
    final matchAsync = ref.watch(matchByIdProvider(widget.matchId));
    final messagesAsync = ref.watch(messagesStreamProvider(widget.matchId));
    final scheme = Theme.of(context).colorScheme;

    final otherAlias = matchAsync.when(
      loading: () => null,
      error: (_, __) => null,
      data: (match) {
        if (match == null || me == null) return null;
        final otherUid = match.otherUid(me.uid);
        return ref.watch(userByIdProvider(otherUid)).value?.alias;
      },
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(kBackIcon, size: 20),
          tooltip: 'Back',
          onPressed: () => context.go('/match/${widget.matchId}'),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            InitialsAvatar(alias: otherAlias ?? '?', radius: 16),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                otherAlias ?? 'Chat',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(kRefreshIcon),
            onPressed: () =>
                ref.invalidate(messagesStreamProvider(widget.matchId)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                loading: () => ListView(
                  reverse: true,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: const [
                    SkeletonBubble(mine: true, width: 160),
                    SkeletonBubble(mine: false, width: 200),
                    SkeletonBubble(mine: true, width: 120),
                    SkeletonBubble(mine: false, width: 220),
                  ],
                ),
                error: (e, _) => AppErrorView(
                  error: e,
                  onRetry: () =>
                      ref.invalidate(messagesStreamProvider(widget.matchId)),
                ),
                data: (messages) {
                  if (me == null) return const SizedBox.shrink();
                  if (messages.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'No messages yet',
                      body: 'Say hi and figure out when to teach each other.',
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final m = messages[i];
                      final older =
                          i + 1 < messages.length ? messages[i + 1] : null;
                      final newer = i - 1 >= 0 ? messages[i - 1] : null;
                      final mine = m.senderUid == me.uid;

                      final isLastInRun = newer == null ||
                          newer.senderUid != m.senderUid ||
                          _gapMinutes(m.createdAt, newer.createdAt) > 5;
                      final isFirstInRun = older == null ||
                          older.senderUid != m.senderUid ||
                          _gapMinutes(older.createdAt, m.createdAt) > 5;

                      final showDaySeparator = m.createdAt != null &&
                          (older == null ||
                              !_sameDay(older.createdAt, m.createdAt));

                      return Column(
                        crossAxisAlignment: mine
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (showDaySeparator)
                            _DaySeparator(date: m.createdAt!),
                          Padding(
                            padding: EdgeInsets.only(
                              top: isFirstInRun ? 8 : 1.5,
                            ),
                            child: _Bubble(
                              message: m,
                              mine: mine,
                              isFirstInRun: isFirstInRun,
                              isLastInRun: isLastInRun,
                            ),
                          ),
                          if (isLastInRun && m.createdAt != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 4, bottom: 4, left: 4, right: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTime(m.createdAt!),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant
                                              .withValues(alpha: 0.7),
                                        ),
                                  ),
                                  if (mine) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.done_all_rounded,
                                      size: 14,
                                      color: scheme.onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(
                  top: BorderSide(color: scheme.onSurface, width: 1.5),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
              child: SafeArea(
                top: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        // firestore.rules rejects messages over 2000 chars.
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(2000),
                        ],
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Type a message…',
                          filled: true,
                          fillColor: scheme.surfaceContainer,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadii.md),
                            borderSide:
                                BorderSide(color: scheme.onSurface, width: 1.2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadii.md),
                            borderSide:
                                BorderSide(color: scheme.onSurface, width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadii.md),
                            borderSide:
                                BorderSide(color: scheme.primary, width: 1.8),
                          ),
                        ),
                        onSubmitted: me == null ? null : (_) => _send(me.uid),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _SendButton(
                      sending: _sending,
                      onTap: (_sending || me == null)
                          ? null
                          : () => _send(me.uid),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.mine,
    required this.isFirstInRun,
    required this.isLastInRun,
  });

  final Message message;
  final bool mine;
  final bool isFirstInRun;
  final bool isLastInRun;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const r = Radius.circular(18);
    const tail = Radius.circular(4);
    final radius = mine
        ? BorderRadius.only(
            topLeft: r,
            topRight: isFirstInRun ? r : tail,
            bottomLeft: r,
            bottomRight: isLastInRun ? tail : r,
          )
        : BorderRadius.only(
            topLeft: isFirstInRun ? r : tail,
            topRight: r,
            bottomLeft: isLastInRun ? tail : r,
            bottomRight: r,
          );

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: mine ? scheme.primary : scheme.surface,
            borderRadius: radius,
            border: Border.all(
              color: mine ? AppColors.terracotta700 : scheme.onSurface,
              width: 1.2,
            ),
          ),
          child: Text(
            message.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: mine ? scheme.onPrimary : scheme.onSurface,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.sending, required this.onTap});

  final bool sending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: disabled ? scheme.surfaceContainerHigh : AppColors.sunburst500,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: disabled ? scheme.outline : AppColors.sunburst700,
              width: 1.5,
            ),
          ),
          child: Center(
            child: sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    Icons.send_rounded,
                    color: disabled ? scheme.outline : Colors.white,
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }
}

class _DaySeparator extends StatelessWidget {
  const _DaySeparator({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
          child: Text(
            _formatDay(date),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ),
      ),
    );
  }
}

bool _sameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

int _gapMinutes(DateTime? a, DateTime? b) {
  if (a == null || b == null) return 0;
  return a.difference(b).inMinutes.abs();
}

String _formatDay(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dDay = DateTime(d.year, d.month, d.day);
  if (dDay == today) return 'Today';
  if (dDay == yesterday) return 'Yesterday';
  if (now.difference(dDay).inDays < 7) {
    return _weekday(d.weekday);
  }
  if (d.year == now.year) {
    return '${_month(d.month)} ${d.day}';
  }
  return '${_month(d.month)} ${d.day}, ${d.year}';
}

String _formatTime(DateTime d) {
  final h24 = d.hour;
  final h = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
  final m = d.minute.toString().padLeft(2, '0');
  final ampm = h24 < 12 ? 'AM' : 'PM';
  return '$h:$m $ampm';
}

String _weekday(int w) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];
String _month(int m) => const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][m - 1];
