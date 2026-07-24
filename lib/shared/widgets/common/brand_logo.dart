import 'package:flutter/material.dart';

import '../../../core/core.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.height = 48,
    this.showWordmark = true,
    this.fit = BoxFit.contain,
  });

  const BrandLogo.appBar({super.key})
    : height = 34,
      showWordmark = true,
      fit = BoxFit.contain;

  const BrandLogo.icon({super.key, this.height = 72})
    : showWordmark = false,
      fit = BoxFit.contain;

  static const appName = 'GymMester';
  static const iconAsset = 'assets/images/appicon.png';
  static const wordmarkAsset = 'assets/images/gymmester logo.png';

  final double height;
  final bool showWordmark;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: appName,
      image: true,
      child: Image.asset(
        showWordmark ? wordmarkAsset : iconAsset,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            appName,
            style: AppTextStyles.h2.copyWith(color: AppColors.primaryBlue),
          );
        },
      ),
    );
  }
}
