import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

extension SvgPictureExtension on String {
  SvgPicture asSvg({BoxFit fit = BoxFit.contain}) =>
      SvgPicture.asset(this, package: "ui_kit", fit: fit);
}
