import 'package:flutter/widgets.dart';


abstract final class SbSpace {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 40.0;


  static const gutter = xl;


  static const rowY = md;


  static const screen = EdgeInsets.fromLTRB(gutter, xxl, gutter, xxxl);


  static const screenUnderAppBar = EdgeInsets.fromLTRB(
    gutter,
    md,
    gutter,
    xxxl,
  );
}


abstract final class SbSize {

  static const focusBar = 56.0;


  static const tapTarget = 48.0;


  static const button = 54.0;


  static const activityGap = 4.0;


  static const activityWeeks = 12;
}
