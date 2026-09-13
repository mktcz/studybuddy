import 'package:flutter/widgets.dart';


abstract final class SbMotion {

  static const quick = Duration(milliseconds: 120);


  static const base = Duration(milliseconds: 200);


  static const slow = Duration(milliseconds: 320);


  static const pulse = Duration(milliseconds: 900);


  static const enter = Curves.easeOutCubic;


  static const exit = Curves.easeInCubic;


  static const standard = Curves.easeInOutCubic;


  static const emphasised = Curves.easeOutQuart;
}
