import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

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
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final bottomPadding = bottomInset + 12;
    const topPadding = 8.0;
    const contentHeight = 58.0;

    return Container(
      height: contentHeight + topPadding + bottomPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
        child: Row(
          children: List.generate(
            items.length,
            (index) => Expanded(
              child: _NavItem(
                icon: items[index].icon,
                label: items[index].label,
                isActive: currentIndex == index,
                isDark: isDark,
                onTap: () => onTap(index),
              ),
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: isActive
                    ? AppColors.primaryBlue
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
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
