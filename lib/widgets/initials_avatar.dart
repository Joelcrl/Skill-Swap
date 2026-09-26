import 'package:flutter/material.dart';

import '../theme.dart';

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.alias, this.radius = 32});

  final String alias;
  final double radius;

  String get _initials {
    final s = alias.trim();
    if (s.isEmpty) return '?';
    final parts = s.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  Color get _bg {
    final palette = AppColors.avatarPalette;
    if (alias.isEmpty) return palette[0];
    final hash = alias.codeUnits.fold<int>(0, (a, c) => a + c);
    return palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _bg,
            Color.lerp(_bg, Colors.black, 0.22)!,
          ],
        ),
        border: Border.all(
          color: scheme.onSurface,
          width: radius < 18 ? 1.0 : 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
          height: 1.0,
        ),
      ),
    );
  }
}
