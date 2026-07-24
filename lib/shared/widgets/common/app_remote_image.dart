import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

Uri? appImageUri(String? path) {
  if (path == null || path.trim().isEmpty) return null;
  final value = path.trim();
  final parsed = Uri.tryParse(value);
  if (parsed != null && parsed.hasScheme) return parsed;

  final base = Uri.parse(AppConfig.apiBaseUrl);
  final normalizedPath = value.startsWith('/') ? value : '/$value';
  return base.replace(path: normalizedPath);
}

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.image,
    required this.fallbackIcon,
    this.size = 52,
    this.backgroundColor,
    this.iconColor = AppColors.primaryBlue,
  });

  final String? image;
  final IconData fallbackIcon;
  final double size;
  final Color? backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final uri = appImageUri(image);
    final radius = BorderRadius.circular(size / 3.2);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: size,
        height: size,
        color: backgroundColor ?? AppColors.primaryBlue.withValues(alpha: 0.12),
        child: uri == null
            ? Icon(fallbackIcon, color: iconColor, size: size * 0.44)
            : Image.network(
                uri.toString(),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Icon(fallbackIcon, color: iconColor, size: size * 0.44),
              ),
      ),
    );
  }
}

class AppRemoteImage extends StatelessWidget {
  const AppRemoteImage({
    super.key,
    required this.image,
    this.height = 132,
    this.width = double.infinity,
    this.borderRadius = DesignTokens.borderRadiusMedium,
  });

  final String? image;
  final double height;
  final double width;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final uri = appImageUri(image);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: width,
        height: height,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.backgroundLight,
        child: uri == null
            ? const Icon(
                IconsaxPlusLinear.gallery,
                color: AppColors.textSecondary,
              )
            : Image.network(
                uri.toString(),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  IconsaxPlusLinear.gallery,
                  color: AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}
