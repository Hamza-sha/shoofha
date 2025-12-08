import 'package:flutter/widgets.dart';

class Responsive {
  Responsive._();

  static Size size(BuildContext context) => MediaQuery.of(context).size;

  static double width(BuildContext context) => size(context).width;

  static double height(BuildContext context) => size(context).height;

  static bool isMobile(BuildContext context) => width(context) < 600;

  static bool isTablet(BuildContext context) =>
      width(context) >= 600 && width(context) < 1024;

  static bool isDesktop(BuildContext context) => width(context) >= 1024;

  static double wp(BuildContext context, double percent) =>
      width(context) * percent;

  static double hp(BuildContext context, double percent) =>
      height(context) * percent;
}
