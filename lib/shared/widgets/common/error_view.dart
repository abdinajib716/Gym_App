import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// ErrorView Widget
/// Displays error state with retry option
class ErrorView extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorView({
    Key? key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon = IconsaxPlusLinear.danger,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.error,
              ),
            ),
            
            const SizedBox(height: DesignTokens.spacing24),
            
            // Title
            Text(
              title ?? 'Oops! Something went wrong',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: DesignTokens.spacing12),
            
            // Error Message
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (onRetry != null) ...[
              const SizedBox(height: DesignTokens.spacing24),
              
              // Retry Button
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(IconsaxPlusLinear.refresh, size: 20),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.textWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: DesignTokens.borderRadiusLarge,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing24,
                    vertical: DesignTokens.spacing12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined error views for common scenarios
class ErrorViews {
  static Widget networkError({VoidCallback? onRetry}) {
    return ErrorView(
      icon: IconsaxPlusLinear.wifi,
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.',
      onRetry: onRetry,
    );
  }

  static Widget serverError({VoidCallback? onRetry}) {
    return ErrorView(
      icon: IconsaxPlusLinear.cloud_cross,
      title: 'Server Error',
      message: 'Something went wrong on our end. Please try again later.',
      onRetry: onRetry,
    );
  }

  static Widget notFound() {
    return const ErrorView(
      icon: IconsaxPlusLinear.search_normal_1,
      title: '404 Not Found',
      message: 'The page you\'re looking for doesn\'t exist.',
    );
  }

  static Widget unauthorized({VoidCallback? onRetry}) {
    return ErrorView(
      icon: IconsaxPlusLinear.lock,
      title: 'Unauthorized',
      message: 'Please log in to access this content.',
      onRetry: onRetry,
    );
  }
}
