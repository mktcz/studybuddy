import 'package:flutter/widgets.dart';


abstract final class SbRadius {

  static const card = Radius.circular(2);


  static const sheet = Radius.circular(16);


  static const pill = Radius.circular(999);

  static const cardAll = BorderRadius.all(card);
  static const sheetTop = BorderRadius.vertical(top: sheet);
  static const pillAll = BorderRadius.all(pill);
}


abstract final class SbStroke {

  static const hairline = 1.0;


  static const emphasis = 0.8;


  static const glyph = 1.5;


  static const arc = 4.0;
}
