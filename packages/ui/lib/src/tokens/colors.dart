import 'package:flutter/material.dart';


abstract final class SbPalette {


  static const canvas = Color(0xFFF5F2EA);


  static const ink = Color(0xFF181A17);


  static const muted = Color(0xFF6F7169);


  static const line = Color(0xFFD8D5CB);


  static const accent = Color(0xFF54735F);


  static const danger = Color(0xFF91483B);


  static const raised = Color(0xFFE9E5DB);


  static const canvasDark = Color(0xFF111310);
  static const inkDark = Color(0xFFF4F0E7);
  static const mutedDark = Color(0xFF9AA096);
  static const lineDark = Color(0xFF2A2E27);
  static const accentDark = Color(0xFFB8D8C0);
  static const dangerDark = Color(0xFFD08A78);
  static const raisedDark = Color(0xFF1D211B);
}


abstract final class SbAlpha {

  static const fill = 0.09;


  static const glyphFill = 0.12;


  static const border = 0.35;


  static const obscured = 0.42;


  static const glyphStroke = 0.74;


  static const scrim = 0.92;


  static const disabled = 0.38;
}


@immutable
class SbColors extends ThemeExtension<SbColors> {
  const SbColors({
    required this.canvas,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    required this.danger,
    required this.raised,
    required this.activity,
    required this.subjects,
  });


  final Color canvas;


  final Color ink;


  final Color muted;


  final Color line;


  final Color accent;


  final Color danger;


  final Color raised;


  final List<Color> activity;


  final List<Color> subjects;


  Color activityLevel(int level) =>
      activity[level.clamp(0, activity.length - 1)];

  Color subject(int accentIndex) => subjects[accentIndex % subjects.length];

  static const light = SbColors(
    canvas: SbPalette.canvas,
    ink: SbPalette.ink,
    muted: SbPalette.muted,
    line: SbPalette.line,
    accent: SbPalette.accent,
    danger: SbPalette.danger,
    raised: SbPalette.raised,
    activity: [
      Color(0xFFE7E3D9),
      Color(0xFFD7E0D7),
      Color(0xFFAFC2B2),
      Color(0xFF78947F),
      Color(0xFF3E644B),
    ],
    subjects: [
      Color(0xFF54735F),
      Color(0xFF8A655C),
      Color(0xFFB66E3D),
      Color(0xFF747D8C),
      Color(0xFF7D8067),
      Color(0xFF7A5B6E),
      Color(0xFF4E7A76),
      Color(0xFF9A8248),
    ],
  );

  static const dark = SbColors(
    canvas: SbPalette.canvasDark,
    ink: SbPalette.inkDark,
    muted: SbPalette.mutedDark,
    line: SbPalette.lineDark,
    accent: SbPalette.accentDark,
    danger: SbPalette.dangerDark,
    raised: SbPalette.raisedDark,
    activity: [
      Color(0xFF1B1E1A),
      Color(0xFF24402E),
      Color(0xFF35603F),
      Color(0xFF4E8459),
      Color(0xFF7FB88C),
    ],
    subjects: [
      Color(0xFFB8D8C0),
      Color(0xFFC9A79D),
      Color(0xFFE0A06E),
      Color(0xFFA3ACBB),
      Color(0xFFB2B593),
      Color(0xFFB893A6),
      Color(0xFF86B6B1),
      Color(0xFFCDB47A),
    ],
  );

  @override
  SbColors copyWith({
    Color? canvas,
    Color? ink,
    Color? muted,
    Color? line,
    Color? accent,
    Color? danger,
    Color? raised,
    List<Color>? activity,
    List<Color>? subjects,
  }) {
    return SbColors(
      canvas: canvas ?? this.canvas,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      accent: accent ?? this.accent,
      danger: danger ?? this.danger,
      raised: raised ?? this.raised,
      activity: activity ?? this.activity,
      subjects: subjects ?? this.subjects,
    );
  }

  @override
  SbColors lerp(SbColors? other, double t) {
    if (other == null) return this;
    return SbColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      activity: _lerpAll(activity, other.activity, t),
      subjects: _lerpAll(subjects, other.subjects, t),
    );
  }

  static List<Color> _lerpAll(List<Color> a, List<Color> b, double t) {
    return List<Color>.generate(
      a.length,
      (i) => Color.lerp(a[i], i < b.length ? b[i] : a[i], t)!,
      growable: false,
    );
  }
}
