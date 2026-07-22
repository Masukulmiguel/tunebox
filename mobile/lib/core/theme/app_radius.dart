import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXXL = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(999));

  static BorderRadius radiusCustom(double r) =>
      BorderRadius.all(Radius.circular(r));

  static const BorderRadius cardRadius = radiusMD;
  static const BorderRadius buttonRadius = radiusLG;
  static const BorderRadius inputRadius = radiusMD;
  static const BorderRadius chipRadius = radiusSM;
  static const BorderRadius bottomSheetRadius = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );
  static const BorderRadius dialogRadius = radiusXL;
  static const BorderRadius imageRadius = radiusSM;
  static const BorderRadius avatarRadius = radiusFull;
}
