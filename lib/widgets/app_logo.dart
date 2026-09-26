import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo._({this.size = 28});

  /// Big wordmark for sign-in / sign-up / splash.
  const AppLogo.large() : this._(size: 36);

  /// Compact wordmark for floating top-left placement.
  const AppLogo.compact() : this._(size: 18);

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final word = GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w900,
      letterSpacing: -size * 0.025,
      color: scheme.onSurface,
      height: 1.0,
    );
    final accentWord = GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w900,
      letterSpacing: -size * 0.025,
      color: AppColors.sunburst500,
      height: 1.0,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Skill', style: word),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size * 0.18),
          child: Container(
            width: size * 0.5,
            height: size * 0.25,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Text('Swap', style: accentWord),
      ],
    );
  }
}
