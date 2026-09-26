import 'package:flutter/material.dart';

/// A circular floating icon button — thin wrapper around stock [IconButton]
/// so the framework owns all the Material/InkWell/MouseRegion choreography.
/// Used as overlay controls when a screen drops the AppBar.
class FloatingIconButton extends StatelessWidget {
  const FloatingIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 48,
    this.iconSize = 20,
    this.tinted = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;

  /// When true, render with a primary-tinted background to mark it as a
  /// "themed" action.
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = tinted ? scheme.primaryContainer : scheme.surface;
    final fg = tinted ? scheme.onPrimaryContainer : scheme.onSurface;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, size: iconSize),
          style: IconButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            disabledForegroundColor: scheme.outline,
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            minimumSize: Size(size, size),
            fixedSize: Size(size, size),
          ),
        ),
      ),
    );
  }
}

/// Standard back-arrow icon for the whole app.
const IconData kBackIcon = Icons.arrow_back_ios_new_rounded;

/// Standard refresh icon — `cached_rounded` reads more like "sync" than
/// the default refresh circle.
const IconData kRefreshIcon = Icons.cached_rounded;

/// Padding to clear the floating overlay row at the top of a screen that uses
/// [FloatingIconButton]s.
const double kFloatingHeaderHeight = 64;
