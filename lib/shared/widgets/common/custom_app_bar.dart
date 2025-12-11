import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// CustomAppBar Widget
/// Reusable app bar with consistent styling
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBackButton;
  final bool centerTitle;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final bool transparent;
  final double elevation;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.centerTitle = true,
    this.actions,
    this.onBackPressed,
    this.backgroundColor,
    this.transparent = false,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      backgroundColor: transparent 
          ? Colors.transparent 
          : (backgroundColor ?? (isDark ? AppColors.darkBackground : AppColors.backgroundWhite)),
      elevation: elevation,
      centerTitle: centerTitle,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                IconsaxPlusLinear.arrow_left,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                )
              : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(DesignTokens.appBarHeight);
}

/// SimpleAppBar - Minimal app bar for simple screens
class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const SimpleAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      showBackButton: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(DesignTokens.appBarHeight);
}
