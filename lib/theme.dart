import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Brand — Terracotta (primary)
  static const terracotta50  = Color(0xFFFBF1ED);
  static const terracotta100 = Color(0xFFF6DDD3);
  static const terracotta200 = Color(0xFFEBBBA6);
  static const terracotta300 = Color(0xFFDA957A);
  static const terracotta400 = Color(0xFFCD7E63);
  static const terracotta500 = Color(0xFFC76F5C);
  static const terracotta600 = Color(0xFFC26B5A); // anchor — primary
  static const terracotta700 = Color(0xFFA8543F);
  static const terracotta800 = Color(0xFF863F2D);
  static const terracotta900 = Color(0xFF5C2A1D);
  static const terracotta950 = Color(0xFF2A1612);

  // Brand — Sage (secondary)
  static const sage50  = Color(0xFFF1F4EF);
  static const sage100 = Color(0xFFDDE4D9);
  static const sage200 = Color(0xFFBCC9B6);
  static const sage300 = Color(0xFFA1B39A);
  static const sage400 = Color(0xFF95AB8E);
  static const sage500 = Color(0xFF8FA68E); // anchor — secondary
  static const sage600 = Color(0xFF708A6E);
  static const sage700 = Color(0xFF54695A);
  static const sage800 = Color(0xFF3B4D40);
  static const sage900 = Color(0xFF243029);
  static const sage950 = Color(0xFF111914);

  // Neutrals — Linen (warm)
  static const linen50  = Color(0xFFF5EDE0); // anchor — surface
  static const linen100 = Color(0xFFEBE2D0);
  static const linen200 = Color(0xFFD9CDB9);
  static const linen300 = Color(0xFFBFB096);
  static const linen400 = Color(0xFF98886F);
  static const linen500 = Color(0xFF756753);
  static const linen600 = Color(0xFF5A4F40);
  static const linen700 = Color(0xFF463D32);
  static const linen800 = Color(0xFF3D332A); // anchor — text
  static const linen900 = Color(0xFF2D2520);
  static const linen950 = Color(0xFF1A1411);

  // Custom dark surfaces (warm cocoa, replaces cool slate)
  static const darkBg            = Color(0xFF1A1411);
  static const darkSurface       = Color(0xFF221B16);
  static const darkSurfaceMuted  = Color(0xFF2A2118);
  static const darkOutline       = Color(0xFF3D332A);
  static const darkOutlineFaint  = Color(0xFF2A2018);

  // Semantic — amber kept for stars; red retuned to fit warm palette
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);

  // Sunburst — high-energy CTA pop, used sparingly (swipe Like, Submit Rating).
  // Sits OUTSIDE the ColorScheme so it doesn't override Material defaults.
  static const sunburst100 = Color(0xFFFFE5D2);
  static const sunburst300 = Color(0xFFFBAC73);
  static const sunburst500 = Color(0xFFF97316);
  static const sunburst700 = Color(0xFFC2410C);
  static const sunburst900 = Color(0xFF7C2D12);

  static const red100 = Color(0xFFF8DAD8);
  static const red400 = Color(0xFFE47670);
  static const red500 = Color(0xFFD5524A);
  static const red900 = Color(0xFF6B2421);

  // Avatar palette — kept (uses direct hex, multi-color by design)
  static const avatarPalette = <Color>[
    Color(0xFF6366F1), // indigo
    Color(0xFFA855F7), // violet
    Color(0xFFEC4899), // pink
    Color(0xFFF97316), // orange
    Color(0xFFF59E0B), // amber
    Color(0xFF14B8A6), // teal
    Color(0xFF22C55E), // green
    Color(0xFF0EA5E9), // sky
  ];
}

class AppRadii {
  AppRadii._();
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double xxl = 20;
  static const double full = 999;
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

ThemeData buildLightTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.terracotta600,
    onPrimary: Colors.white,
    primaryContainer: AppColors.terracotta100,
    onPrimaryContainer: AppColors.terracotta900,
    secondary: AppColors.sage500,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.sage100,
    onSecondaryContainer: AppColors.sage900,
    tertiary: AppColors.amber500,
    onTertiary: Colors.white,
    error: AppColors.red500,
    onError: Colors.white,
    errorContainer: AppColors.red100,
    onErrorContainer: AppColors.red900,
    surface: AppColors.linen50,
    onSurface: AppColors.linen800,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: AppColors.linen50,
    surfaceContainer: AppColors.linen100,
    surfaceContainerHigh: AppColors.linen100,
    surfaceContainerHighest: AppColors.linen200,
    onSurfaceVariant: AppColors.linen600,
    outline: AppColors.linen200,
    outlineVariant: AppColors.linen100,
    inverseSurface: AppColors.linen800,
    onInverseSurface: AppColors.linen100,
    inversePrimary: AppColors.terracotta300,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );
  return _buildTheme(scheme);
}

ThemeData buildDarkTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.terracotta400,
    onPrimary: AppColors.terracotta950,
    primaryContainer: AppColors.terracotta900,
    onPrimaryContainer: AppColors.terracotta100,
    secondary: AppColors.sage400,
    onSecondary: AppColors.sage900,
    secondaryContainer: AppColors.sage900,
    onSecondaryContainer: AppColors.sage100,
    tertiary: AppColors.amber400,
    onTertiary: AppColors.linen900,
    error: AppColors.red400,
    onError: AppColors.linen900,
    errorContainer: AppColors.red900,
    onErrorContainer: AppColors.red100,
    surface: AppColors.darkSurface,
    onSurface: AppColors.linen100,
    surfaceContainerLowest: AppColors.darkBg,
    surfaceContainerLow: AppColors.darkSurface,
    surfaceContainer: AppColors.darkSurfaceMuted,
    surfaceContainerHigh: AppColors.darkSurfaceMuted,
    surfaceContainerHighest: AppColors.darkOutline,
    onSurfaceVariant: AppColors.linen400,
    outline: AppColors.darkOutline,
    outlineVariant: AppColors.darkOutlineFaint,
    inverseSurface: AppColors.linen100,
    onInverseSurface: AppColors.linen900,
    inversePrimary: AppColors.terracotta700,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );
  return _buildTheme(scheme);
}

ThemeData _buildTheme(ColorScheme scheme) {
  final isDark = scheme.brightness == Brightness.dark;
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        isDark ? AppColors.darkBg : AppColors.linen50,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
  );

  // Plus Jakarta Sans throughout — single family, hierarchy via weight + size.
  TextStyle pj({
    required double size,
    required FontWeight weight,
    double? height,
    double letter = 0,
    Color? color,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letter,
      color: color ?? scheme.onSurface,
    );
  }

  final textTheme =
      GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
    displayLarge: pj(size: 44, weight: FontWeight.w800, letter: -1.0, height: 1.02),
    displayMedium: pj(size: 38, weight: FontWeight.w800, letter: -0.8, height: 1.05),
    displaySmall: pj(size: 32, weight: FontWeight.w800, letter: -0.6, height: 1.08),
    headlineLarge: pj(size: 28, weight: FontWeight.w800, letter: -0.4, height: 1.15),
    headlineMedium: pj(size: 24, weight: FontWeight.w700, letter: -0.3, height: 1.2),
    headlineSmall: pj(size: 20, weight: FontWeight.w700, letter: -0.2, height: 1.25),
    titleLarge: pj(size: 18, weight: FontWeight.w600, letter: -0.1, height: 1.3),
    titleMedium: pj(size: 16, weight: FontWeight.w600, height: 1.35),
    titleSmall: pj(size: 14, weight: FontWeight.w600, height: 1.4),
    bodyLarge: pj(size: 16, weight: FontWeight.w400, height: 1.55),
    bodyMedium: pj(
      size: 14,
      weight: FontWeight.w400,
      height: 1.5,
      color: scheme.onSurfaceVariant,
    ),
    bodySmall: pj(
      size: 13,
      weight: FontWeight.w400,
      height: 1.45,
      color: scheme.onSurfaceVariant,
    ),
    labelLarge: pj(size: 14, weight: FontWeight.w600, letter: 0.1),
    labelMedium: pj(size: 12, weight: FontWeight.w600, letter: 0.2),
    labelSmall: pj(
      size: 11,
      weight: FontWeight.w600,
      letter: 0.4,
      color: scheme.onSurfaceVariant,
    ),
  );

  return base.copyWith(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
      iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        side: BorderSide(color: scheme.outline, width: 1),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        disabledBackgroundColor:
            scheme.onSurface.withValues(alpha: 0.08),
        disabledForegroundColor:
            scheme.onSurface.withValues(alpha: 0.38),
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outline, width: 1.2),
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? scheme.surfaceContainer
          : scheme.surfaceContainerLow,
      isDense: false,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      helperStyle: textTheme.bodySmall,
      errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: scheme.outline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: scheme.outline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: scheme.error, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: scheme.error, width: 1.6),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainer,
      selectedColor: scheme.primaryContainer,
      side: BorderSide(color: scheme.outline, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      labelStyle: textTheme.labelMedium,
      secondaryLabelStyle: textTheme.labelMedium?.copyWith(
        color: scheme.onPrimaryContainer,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 16),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle:
          textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
      actionTextColor: scheme.inversePrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      titleTextStyle: textTheme.titleMedium,
      subtitleTextStyle: textTheme.bodySmall,
      iconColor: scheme.onSurfaceVariant,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHigh,
      circularTrackColor: scheme.surfaceContainerHigh,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      textStyle:
          textTheme.bodySmall?.copyWith(color: scheme.onInverseSurface),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: scheme.primaryContainer,
      indicatorShape: const StadiumBorder(),
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
          size: 24,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          letterSpacing: 0.3,
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
        );
      }),
    ),
  );
}
