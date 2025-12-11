import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography System - Poppins Font Family
/// Reusable text styles for consistent typography
class AppTextStyles {
  // Prevent instantiation
  AppTextStyles._();

  // Font Family - Change to your preferred font
  static const String fontFamily = 'Poppins';
  
  // ============================================
  // HEADINGS
  // ============================================
  
  /// H1 - Large Heading (22px SemiBold)
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.44,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  
  /// H2 - Medium Heading (16px SemiBold)
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.32,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  
  /// H3 - Small Heading (14px SemiBold)
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.28,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  
  // ============================================
  // BODY TEXT
  // ============================================
  
  /// Body Large (16px Regular)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.32,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  
  /// Body Medium (14px Regular)
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.28,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  
  /// Body Small (12px Regular)
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.24,
    height: 1.5,
    color: AppColors.textSecondary,
  );
  
  // ============================================
  // LABELS & BUTTONS
  // ============================================
  
  /// Label Medium (12px Medium)
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.24,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  
  /// Label Small (10px SemiBold)
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  
  /// Caption (10px Medium)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.5,
    color: AppColors.textSecondary,
  );
  
  /// Button Text (14px SemiBold)
  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.28,
    color: AppColors.textWhite,
  );
  
  /// Price Text (16px Bold)
  static const TextStyle priceText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryBlue,
  );
}
