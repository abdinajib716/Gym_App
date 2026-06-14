import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// BottomNavBar Widget
/// Reusable bottom navigation bar - customize items as needed
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: DesignTokens.bottomNavHeight,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            items.length,
            (index) => _NavItem(
              icon: items[index].icon,
              label: items[index].label,
              isActive: currentIndex == index,
              isDark: isDark,
              onTap: () => onTap(index),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom Nav Item Data
class BottomNavItem {
  final IconData icon;
  final String label;

  const BottomNavItem({required this.icon, required this.label});
}

/// Individual Navigation Item
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive
                  ? AppColors.primaryBlue
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isActive
                    ? AppColors.primaryBlue
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Default nav items example - customize for your app
class DefaultNavItems {
  static const List<BottomNavItem> items = [
    BottomNavItem(icon: IconsaxPlusLinear.home_1, label: 'Home'),
    BottomNavItem(icon: IconsaxPlusLinear.search_normal_1, label: 'Search'),
    BottomNavItem(icon: IconsaxPlusLinear.heart, label: 'Favorites'),
    BottomNavItem(icon: IconsaxPlusLinear.profile, label: 'Profile'),
  ];
}
