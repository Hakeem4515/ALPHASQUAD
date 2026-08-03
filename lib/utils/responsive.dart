import 'package:flutter/material.dart';

/// Helper utility for responsive screen layouts in SOLARX.
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Mobile screen breakpoint (< 600px)
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  /// Tablet screen breakpoint (600px - 1024px)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600 && width < 1024;
  }

  /// Desktop / Large Tablet landscape breakpoint (>= 1024px)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  /// Utility to get screen width
  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  /// Utility to get screen height
  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;

  /// Value selector based on breakpoint
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 1024 && desktop != null) return desktop;
    if (w >= 600 && tablet != null) return tablet;
    return mobile;
  }

  /// Returns max content width based on device width
  static double maxContentWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 1200) return 1200;
    if (w >= 900) return 960;
    if (w >= 600) return 768;
    return 430; // Mobile default
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024 && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}
