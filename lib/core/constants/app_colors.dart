import 'package:flutter/material.dart';

/// App Color Palette - Reusable UI Kit
/// Customize these colors for your app brand
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ============================================
  // PRIMARY BRAND COLORS
  // ============================================
  static const Color primaryBlue = Color(0xFF233973);
  static const Color primaryBlueDark = Color(0xFF07094F);

  // ============================================
  // ACCENT COLORS
  // ============================================
  static const Color accentPurple = Color(0xFF8959C1);
  static const Color accentLightPurple = Color(0xFFCFB1FC);
  static const Color accentPink = Color(0xFFF98066);
  static const Color accentOrange = Color(0xFFFCA260);

  // ============================================
  // BACKGROUND COLORS
  // ============================================
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ============================================
  // TEXT COLORS
  // ============================================
  static const Color textPrimary = Color(0xFF233973);
  static const Color textSecondary = Color(0xFF8B93A5);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textWhiteTransparent = Color(0xCCFFFFFF); // 80% opacity

  // ============================================
  // UI ELEMENT COLORS
  // ============================================
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x0A07094F);
  static const Color shadowDark = Color(0x1A07094F);
  static const Color blur = Color(0x5E233973);

  // ============================================
  // STATUS COLORS
  // ============================================
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFB00020);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // ============================================
  // DARK THEME COLORS
  // ============================================
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF252525);
  static const Color darkTextPrimary = Color(0xFFE1E1E1);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkDivider = Color(0xFF2C2C2C);

  // ============================================
  // GRADIENTS
  // ============================================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentPurple, accentLightPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
