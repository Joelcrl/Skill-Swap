import 'package:flutter/material.dart';

import '../theme.dart';

class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = AppRadii.sm,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        final color = Color.lerp(
          scheme.surfaceContainer,
          scheme.surfaceContainerHighest,
          t,
        )!;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: widget.shape == BoxShape.circle
              ? BoxDecoration(color: color, shape: BoxShape.circle)
              : BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(widget.radius),
                ),
        );
      },
    );
  }
}

class SkeletonAvatar extends StatelessWidget {
  const SkeletonAvatar({super.key, this.radius = 32});
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: radius * 2,
      height: radius * 2,
      shape: BoxShape.circle,
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 140});
  final double height;

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(height: 14, width: 120),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 12, width: double.infinity),
            SizedBox(height: AppSpacing.sm),
            SkeletonBox(height: 12, width: 220),
          ],
        ),
      ),
    );
  }
}

class SkeletonBubble extends StatelessWidget {
  const SkeletonBubble({super.key, this.mine = false, this.width = 180});
  final bool mine;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: SkeletonBox(
          width: width,
          height: 36,
          radius: AppRadii.lg,
        ),
      ),
    );
  }
}
