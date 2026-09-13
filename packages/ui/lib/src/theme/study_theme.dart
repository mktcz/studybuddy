import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/motion.dart';
import '../tokens/shape.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';


extension SbThemeContext on BuildContext {

  SbColors get sb => Theme.of(this).extension<SbColors>() ?? SbColors.light;


  TextTheme get text => Theme.of(this).textTheme;
}


ThemeData studyTheme({Brightness brightness = Brightness.light}) {
  final isDark = brightness == Brightness.dark;
  final sb = isDark ? SbColors.dark : SbColors.light;

  final scheme =
      ColorScheme.fromSeed(
        seedColor: sb.accent,
        brightness: brightness,
      ).copyWith(
        surface: sb.canvas,
        onSurface: sb.ink,


        onSurfaceVariant: sb.muted,
        outline: sb.line,
        outlineVariant: sb.line,
        error: sb.danger,
        onError: sb.canvas,
      );

  final textTheme = SbType.textTheme(ink: sb.ink, muted: sb.muted);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: sb.canvas,
    canvasColor: sb.canvas,
    dividerColor: sb.line,
    splashFactory: InkSparkle.splashFactory,
    extensions: <ThemeExtension<dynamic>>[sb],
    textTheme: textTheme,

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()},
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: sb.canvas,
      foregroundColor: sb.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),

    dividerTheme: DividerThemeData(
      color: sb.line,
      thickness: SbStroke.hairline,
      space: SbStroke.hairline,
    ),


    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      hintStyle: textTheme.bodyLarge?.copyWith(color: sb.muted),
      border: UnderlineInputBorder(borderSide: BorderSide(color: sb.line)),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: sb.line),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: sb.ink),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: sb.danger),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: SbSpace.sm),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: sb.ink,
        foregroundColor: sb.canvas,
        disabledBackgroundColor: sb.ink.withValues(alpha: SbAlpha.disabled),
        disabledForegroundColor: sb.canvas.withValues(alpha: SbAlpha.scrim),
        minimumSize: const Size.fromHeight(SbSize.button),
        textStyle: textTheme.labelLarge,
        shape: const RoundedRectangleBorder(borderRadius: SbRadius.cardAll),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: sb.ink,
        minimumSize: const Size.fromHeight(SbSize.button),
        side: BorderSide(color: sb.line),
        textStyle: textTheme.labelLarge,
        shape: const RoundedRectangleBorder(borderRadius: SbRadius.cardAll),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: sb.ink,
        textStyle: textTheme.labelLarge,
      ),
    ),

    iconTheme: IconThemeData(color: sb.ink, size: 20),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: sb.ink),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: sb.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(borderRadius: SbRadius.sheetTop),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: sb.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyLarge,
      shape: const RoundedRectangleBorder(borderRadius: SbRadius.cardAll),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: sb.canvas,
      surfaceTintColor: Colors.transparent,
      indicatorColor: sb.accent.withValues(alpha: SbAlpha.fill),
      elevation: 0,
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? textTheme.labelMedium?.copyWith(color: sb.ink)
            : textTheme.labelMedium?.copyWith(color: sb.muted),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected) ? sb.ink : sb.muted,
        ),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: sb.ink,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: sb.canvas),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: SbRadius.cardAll),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: sb.accent,
      linearMinHeight: 2,
      circularTrackColor: sb.line,
      linearTrackColor: sb.line,
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: sb.ink, borderRadius: SbRadius.cardAll),
      textStyle: textTheme.bodySmall?.copyWith(color: sb.canvas),
      waitDuration: SbMotion.slow,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? sb.canvas : sb.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? sb.accent : sb.line,
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );
}
