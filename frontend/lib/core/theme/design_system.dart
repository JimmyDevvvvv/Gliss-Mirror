import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design tokens for the Gliss Mirror app.
/// This class defines the foundational elements of the design system.
class DesignTokens {
  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 350);
  static const Duration animVerySlow = Duration(milliseconds: 500);

  // Animation Curves
  static const Curve easeOutCurve = Curves.easeOutCubic;
  static const Curve easeInOutCurve = Curves.easeInOutCubic;
  static const Curve bounceOutCurve = Curves.easeOutBack;

  // Spacing System (8px Grid)
  static const double spacing1 = 8;
  static const double spacing2 = 16;
  static const double spacing3 = 24;
  static const double spacing4 = 32;
  static const double spacing5 = 40;
  static const double spacing6 = 48;
  static const double spacing7 = 64;

  // Border Radiuses
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 24;
  static const double radiusCircular = 999;

  // Opacity Levels
  static const double opacityDisabled = 0.38;
  static const double opacityLight = 0.16;
  static const double opacityMedium = 0.32;
  static const double opacityHeavy = 0.64;

  // Shadows
  static List<BoxShadow> get elevation1 => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevation2 => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevation3 => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Touch Targets
  static const double minTouchTarget = 44;
  static const EdgeInsets minTouchTargetPadding = EdgeInsets.all(8);

  // Status Bar Styles
  static const SystemUiOverlayStyle lightStatusBar = SystemUiOverlayStyle.light;
  static const SystemUiOverlayStyle darkStatusBar = SystemUiOverlayStyle.dark;
}

/// Extension methods for common design patterns
extension DesignHelpers on Widget {
  Widget withPadding(EdgeInsets padding) {
    return Padding(padding: padding, child: this);
  }

  Widget withMargin(EdgeInsets margin) {
    return Container(margin: margin, child: this);
  }

  Widget withElevation(List<BoxShadow> elevation) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: elevation,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      ),
      child: this,
    );
  }

  Widget withTouchTarget() {
    return Container(
      constraints: const BoxConstraints(
        minWidth: DesignTokens.minTouchTarget,
        minHeight: DesignTokens.minTouchTarget,
      ),
      padding: DesignTokens.minTouchTargetPadding,
      child: this,
    );
  }
}
