import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Application Constants
class AppConstants {
  AppConstants._();

  // App Info - Change for your app
  static const String appName = 'My App';
  static const String appVersion = '1.0.0';

  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration slowAnimation = Duration(milliseconds: 500);
}

/// Design Tokens - Measurements & Spacing
class DesignTokens {
  DesignTokens._();

  // ============================================
  // SCREEN DIMENSIONS
  // ============================================
  static const double screenWidth = 375.0;
  static const double screenPadding = 22.0;
  static const double contentWidth = 355.0;

  // ============================================
  // COMPONENT HEIGHTS
  // ============================================
  static const double bottomNavHeight = 90.0;
  static const double appBarHeight = 56.0;

  // ============================================
  // BORDER RADIUS
  // ============================================
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusXXLarge = 24.0;

  static const BorderRadius borderRadiusSmall = BorderRadius.all(
    Radius.circular(radiusSmall),
  );
  static const BorderRadius borderRadiusMedium = BorderRadius.all(
    Radius.circular(radiusMedium),
  );
  static const BorderRadius borderRadiusLarge = BorderRadius.all(
    Radius.circular(radiusLarge),
  );
  static const BorderRadius borderRadiusXLarge = BorderRadius.all(
    Radius.circular(radiusXLarge),
  );
  static const BorderRadius borderRadiusXXLarge = BorderRadius.all(
    Radius.circular(radiusXXLarge),
  );

  // ============================================
  // SPACING SCALE
  // ============================================
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;

  // ============================================
  // ICON SIZES
  // ============================================
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // ============================================
  // BUTTON HEIGHTS
  // ============================================
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;
}

/// Shadow Definitions
class AppShadows {
  AppShadows._();

  static const BoxShadow cardShadow = BoxShadow(
    color: AppColors.shadow,
    blurRadius: 20,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  static const BoxShadow navShadow = BoxShadow(
    color: AppColors.shadowDark,
    blurRadius: 30,
    offset: Offset(0, -7),
    spreadRadius: 0,
  );

  static const BoxShadow elevatedShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 12,
    offset: Offset(0, 6),
    spreadRadius: -2,
  );

  static const List<BoxShadow> cardShadows = [cardShadow];
  static const List<BoxShadow> navShadows = [navShadow];
  static const List<BoxShadow> elevatedShadows = [elevatedShadow];
}

/// Input Decoration Theme
class AppInputDecoration {
  AppInputDecoration._();

  static InputDecoration textFieldDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.backgroundLight,
      border: const OutlineInputBorder(
        borderRadius: DesignTokens.borderRadiusLarge,
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: DesignTokens.borderRadiusLarge,
        borderSide: BorderSide.none,
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: DesignTokens.borderRadiusLarge,
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: DesignTokens.borderRadiusLarge,
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing16,
        vertical: DesignTokens.spacing16,
      ),
    );
  }
}
