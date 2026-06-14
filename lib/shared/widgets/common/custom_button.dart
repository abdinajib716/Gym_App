import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// CustomButton Widget
/// Reusable button with primary, secondary, and outline variants
///
/// Uses [IconsaxPlusLinear] for high-quality icons. Example:
/// ```dart
/// CustomButton(
///   text: 'Continue',
///   icon: IconsaxPlusLinear.arrow_right_1,
///   onPressed: () {},
/// )
/// ```
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.fullWidth = true,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getTextColor(),
          elevation: type == ButtonType.outline ? 0 : 2,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.borderRadiusLarge,
            side: type == ButtonType.outline
                ? const BorderSide(color: AppColors.primaryBlue, width: 1.5)
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing16,
            vertical: size == ButtonSize.small
                ? DesignTokens.spacing8
                : DesignTokens.spacing12,
          ),
        ),
        child: isLoading ? _buildLoadingIndicator() : _buildButtonContent(),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return DesignTokens.buttonHeightSmall;
      case ButtonSize.large:
        return DesignTokens.buttonHeightLarge;
      case ButtonSize.medium:
        return DesignTokens.buttonHeightMedium;
    }
  }

  Color _getBackgroundColor() {
    if (onPressed == null) {
      return AppColors.textSecondary.withValues(alpha: 0.3);
    }

    switch (type) {
      case ButtonType.secondary:
        return AppColors.accentPurple;
      case ButtonType.outline:
        return Colors.transparent;
      case ButtonType.primary:
        return AppColors.primaryBlue;
    }
  }

  Color _getTextColor() {
    if (onPressed == null) {
      return AppColors.textSecondary;
    }

    switch (type) {
      case ButtonType.outline:
        return AppColors.primaryBlue;
      case ButtonType.primary:
      case ButtonType.secondary:
        return AppColors.textWhite;
    }
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: DesignTokens.spacing8),
          Text(
            text,
            style: AppTextStyles.buttonText.copyWith(color: _getTextColor()),
          ),
        ],
      );
    }

    return Text(
      text,
      style: AppTextStyles.buttonText.copyWith(color: _getTextColor()),
    );
  }
}

enum ButtonType { primary, secondary, outline }

enum ButtonSize { small, medium, large }
