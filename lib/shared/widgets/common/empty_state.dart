import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// EmptyState Widget
/// Displays when there's no data to show
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const EmptyState({
    super.key,
    this.icon = IconsaxPlusLinear.box_1,
    required this.title,
    this.message,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.textSecondary),
            ),

            const SizedBox(height: DesignTokens.spacing24),

            // Title
            Text(title, style: AppTextStyles.h2, textAlign: TextAlign.center),

            if (message != null) ...[
              const SizedBox(height: DesignTokens.spacing12),

              // Message
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: DesignTokens.spacing24),

              // Action Button
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.textWhite,
                  shape: const RoundedRectangleBorder(
                    borderRadius: DesignTokens.borderRadiusLarge,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing24,
                    vertical: DesignTokens.spacing12,
                  ),
                ),
                child: Text(actionText!, style: AppTextStyles.buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined empty states for common scenarios
class EmptyStates {
  static Widget noData({String? message}) {
    return EmptyState(
      icon: IconsaxPlusLinear.box_1,
      title: 'No Data Found',
      message: message ?? 'There is no data to display.',
    );
  }

  static Widget noSearchResults() {
    return const EmptyState(
      icon: IconsaxPlusLinear.search_normal_1,
      title: 'No Results',
      message: 'Try adjusting your search or filters.',
    );
  }

  static Widget emptyList({String? title, String? message}) {
    return EmptyState(
      icon: IconsaxPlusLinear.document,
      title: title ?? 'Empty List',
      message: message ?? 'No items to display.',
    );
  }
}
