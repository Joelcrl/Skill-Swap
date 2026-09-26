import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/swipe.dart';
import '../models/user_profile.dart';
import '../providers/auth_providers.dart';
import '../providers/discovery_providers.dart';
import '../providers/profile_providers.dart';
import '../services/swipe_service.dart';
import '../theme.dart';
import '../utils/swap_fit.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/floating_icon_button.dart';
import '../widgets/profile_card.dart';

const double _kSwipeThreshold = 110;
const double _kStampActivate = 25;

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  bool _busy = false;
  String? _matchedAlias;
  String? _matchedMatchId;

  Offset _drag = Offset.zero;
  late final AnimationController _ctrl;
  Tween<Offset> _tween = Tween(begin: Offset.zero, end: Offset.zero);
  bool _committing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..addListener(_onTick);
  }

  @override
  void dispose() {
    _ctrl
      ..removeListener(_onTick)
      ..dispose();
    super.dispose();
  }

  void _onTick() {
    setState(() {
      _drag = _tween.transform(Curves.easeOut.transform(_ctrl.value));
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_committing || _busy || _ctrl.isAnimating) return;
    setState(() => _drag += d.delta);
  }

  void _onPanEnd(DragEndDetails _) {
    if (_committing || _busy || _ctrl.isAnimating) return;
    final dx = _drag.dx;
    if (dx.abs() > _kSwipeThreshold) {
      _commit(dx > 0 ? SwipeDirection.like : SwipeDirection.pass);
    } else {
      _animateBack();
    }
  }

  void _animateBack() {
    _tween = Tween(begin: _drag, end: Offset.zero);
    _ctrl.forward(from: 0);
  }

  Future<void> _commit(SwipeDirection dir) async {
    _committing = true;
    HapticFeedback.lightImpact();
    final width = MediaQuery.of(context).size.width;
    final target = Offset(
      dir == SwipeDirection.like ? width * 1.4 : -width * 1.4,
      _drag.dy + 80,
    );
    _tween = Tween(begin: _drag, end: target);
    await _ctrl.forward(from: 0);

    final me = ref.read(authStateProvider).value;
    final candidates = ref.read(candidatesProvider).value ?? const [];
    if (me == null || _index >= candidates.length) {
      _resetCard();
      return;
    }
    final other = candidates[_index];
    setState(() {
      _busy = true;
      _matchedAlias = null;
    });
    try {
      final result = await ref.read(swipeServiceProvider).swipe(
            myUid: me.uid,
            otherUid: other.uid,
            direction: dir,
          );
      if (!mounted) return;
      // If a match already exists in active state (matched/inProgress),
      // jump straight to it instead of creating a duplicate.
      if (result.existingMatchActive && result.matchId != null) {
        final id = result.matchId!;
        setState(() {
          _index += 1;
          _busy = false;
        });
        _resetCard();
        if (mounted) context.go('/match/$id');
        return;
      }
      setState(() {
        _index += 1;
        _busy = false;
        if (result.matchCreated) {
          _matchedAlias = other.alias;
          _matchedMatchId = result.matchId;
          HapticFeedback.mediumImpact();
        }
      });
    } on ReSwapTooSoonException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Swipe failed. Please try again.')),
      );
    }
    _resetCard();
  }

  void _resetCard() {
    if (!mounted) return;
    setState(() {
      _drag = Offset.zero;
      _committing = false;
    });
    _ctrl.value = 0;
  }

  void _dismissMatchToast() {
    if (_matchedAlias == null) return;
    setState(() {
      _matchedAlias = null;
      _matchedMatchId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final candidatesAsync = ref.watch(candidatesProvider);
    final myProfile = ref.watch(currentProfileProvider).value;
    final refreshDisabled = _busy || _committing;

    int? fitFor(UserProfile other) {
      if (myProfile == null) return null;
      return swapFitPercent(
        mySkillsOffered: myProfile.skillsOffered,
        mySkillsWanted: myProfile.skillsWanted,
        theirSkillsOffered: other.skillsOffered,
        theirSkillsWanted: other.skillsWanted,
      );
    }
    void doRefresh() {
      ref.invalidate(candidatesProvider);
      setState(() {
        _index = 0;
        _matchedAlias = null;
        _matchedMatchId = null;
        _drag = Offset.zero;
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: kFloatingHeaderHeight),
              child: candidatesAsync.when(
                loading: () => const _SwipeSkeleton(),
                error: (e, _) => AppErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(candidatesProvider),
                ),
                data: (candidates) {
                  if (_index >= candidates.length) {
                    return AppEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No more profiles',
                      body:
                          'Check back soon — new people join all the time.',
                      action: OutlinedButton.icon(
                        onPressed: () {
                          ref.invalidate(candidatesProvider);
                          setState(() => _index = 0);
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Refresh'),
                      ),
                    );
                  }
                  final current = candidates[_index];
                  final next = _index + 1 < candidates.length
                      ? candidates[_index + 1]
                      : null;
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            AnimatedSize(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              child: _matchedAlias != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: AppSpacing.md),
                                      child: _MatchToast(
                                        alias: _matchedAlias!,
                                        onChat: _matchedMatchId == null
                                            ? null
                                            : () {
                                                final id = _matchedMatchId!;
                                                _dismissMatchToast();
                                                context.go('/match/$id/chat');
                                              },
                                        onDismiss: _dismissMatchToast,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            Expanded(
                              child: _CardStack(
                                current: current,
                                next: next,
                                currentFit: fitFor(current),
                                nextFit: next == null ? null : fitFor(next),
                                drag: _drag,
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: _onPanEnd,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _ActionRow(
                              disabled: _busy || _committing,
                              onPass: () => _commit(SwipeDirection.pass),
                              onLike: () => _commit(SwipeDirection.like),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.md,
              child: FloatingIconButton(
                icon: kBackIcon,
                tooltip: 'Back to swaps',
                onPressed: () => context.go('/swaps'),
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.md,
              child: FloatingIconButton(
                icon: kRefreshIcon,
                tooltip: 'Refresh',
                onPressed: refreshDisabled ? null : doRefresh,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardStack extends StatelessWidget {
  const _CardStack({
    required this.current,
    required this.next,
    required this.currentFit,
    required this.nextFit,
    required this.drag,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final UserProfile current;
  final UserProfile? next;
  final int? currentFit;
  final int? nextFit;
  final Offset drag;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;

  @override
  Widget build(BuildContext context) {
    final dx = drag.dx;
    final tilt = (dx / 1400).clamp(-0.18, 0.18);
    final likeOpacity = ((dx - _kStampActivate) / 80).clamp(0.0, 1.0);
    final passOpacity = ((-dx - _kStampActivate) / 80).clamp(0.0, 1.0);
    // Behind-card grows toward 1.0 as front card moves away.
    final progress = (dx.abs() / 200).clamp(0.0, 1.0);
    final backScale = 0.94 + 0.06 * progress;
    final backOffsetY = 12.0 * (1 - progress);

    return LayoutBuilder(
      builder: (_, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            if (next != null)
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, backOffsetY),
                  child: Transform.scale(
                    scale: backScale,
                    child: AbsorbPointer(
                      child: Opacity(
                        opacity: 0.85,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: ProfileCard(profile: next!, swapFit: nextFit),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: Transform.translate(
                offset: drag,
                child: Transform.rotate(
                  angle: tilt,
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: onPanUpdate,
                    onPanEnd: onPanEnd,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: ProfileCard(profile: current, swapFit: currentFit),
                        ),
                        Positioned(
                          top: 24,
                          left: 24,
                          child: _Stamp.like(opacity: likeOpacity),
                        ),
                        Positioned(
                          top: 24,
                          right: 24,
                          child: _Stamp.pass(opacity: passOpacity),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Stamp extends StatelessWidget {
  const _Stamp.like({required this.opacity})
      : label = 'SWAP',
        color = AppColors.sunburst500,
        rotation = -math.pi / 12;
  const _Stamp.pass({required this.opacity})
      : label = 'PASS',
        color = AppColors.red500,
        rotation = math.pi / 12;

  final double opacity;
  final String label;
  final Color color;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0) return const SizedBox.shrink();
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 3),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.disabled,
    required this.onPass,
    required this.onLike,
  });

  final bool disabled;
  final VoidCallback onPass;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _LabeledAction(
          tooltip: 'Pass',
          icon: Icons.close_rounded,
          label: 'Pass',
          background: scheme.surface,
          foreground: AppColors.red500,
          border: scheme.outline,
          onPressed: disabled ? null : onPass,
        ),
        _LabeledAction(
          tooltip: 'Like',
          icon: Icons.favorite_rounded,
          label: 'Swap',
          background: AppColors.sunburst500,
          foreground: Colors.white,
          onPressed: disabled ? null : onLike,
          large: true,
        ),
      ],
    );
  }
}

class _LabeledAction extends StatelessWidget {
  const _LabeledAction({
    required this.tooltip,
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    this.border,
    this.onPressed,
    this.large = false,
  });

  final String tooltip;
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color? border;
  final VoidCallback? onPressed;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleAction(
          tooltip: tooltip,
          icon: icon,
          background: background,
          foreground: foreground,
          border: border,
          onPressed: onPressed,
          large: large,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
                color: onPressed == null
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.tooltip,
    required this.icon,
    required this.background,
    required this.foreground,
    this.border,
    this.onPressed,
    this.large = false,
  });

  final String tooltip;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color? border;
  final VoidCallback? onPressed;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 72.0 : 60.0;
    final iconSize = large ? 32.0 : 26.0;
    final disabled = onPressed == null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: disabled
            ? Theme.of(context).colorScheme.surfaceContainerHigh
            : background,
        shape: CircleBorder(
          side: border != null
              ? BorderSide(color: border!, width: 1.2)
              : BorderSide.none,
        ),
        elevation: large ? 4 : 1,
        shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.3),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: iconSize,
              color: disabled
                  ? Theme.of(context).colorScheme.outline
                  : foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchToast extends StatefulWidget {
  const _MatchToast({
    required this.alias,
    required this.onDismiss,
    required this.onChat,
  });

  final String alias;
  final VoidCallback onDismiss;
  final VoidCallback? onChat;

  @override
  State<_MatchToast> createState() => _MatchToastState();
}

class _MatchToastState extends State<_MatchToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: _ctrl,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.sm, AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                scheme.secondaryContainer,
                scheme.primaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: scheme.secondary.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.handshake_rounded,
                    color: scheme.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "It's a match!",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.onSecondaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      'Say hi to ${widget.alias} and plan your trade.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSecondaryContainer,
                          ),
                    ),
                  ],
                ),
              ),
              if (widget.onChat != null)
                TextButton(
                  onPressed: widget.onChat,
                  child: const Text('Chat'),
                ),
              IconButton(
                tooltip: 'Dismiss',
                onPressed: widget.onDismiss,
                icon: const Icon(Icons.close, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeSkeleton extends StatelessWidget {
  const _SwipeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SkeletonAvatar(radius: 56),
                        SizedBox(height: AppSpacing.md),
                        SkeletonBox(height: 18, width: 120),
                        SizedBox(height: AppSpacing.xs),
                        SkeletonBox(height: 12, width: 80),
                        SizedBox(height: AppSpacing.xl),
                        SkeletonBox(height: 14, width: 100),
                        SizedBox(height: AppSpacing.sm),
                        SkeletonBox(height: 36, width: double.infinity),
                        SizedBox(height: AppSpacing.lg),
                        SkeletonBox(height: 14, width: 100),
                        SizedBox(height: AppSpacing.sm),
                        SkeletonBox(height: 36, width: double.infinity),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  SkeletonBox(height: 60, width: 60, radius: AppRadii.full),
                  SkeletonBox(height: 72, width: 72, radius: AppRadii.full),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
