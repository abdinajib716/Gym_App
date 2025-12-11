import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import '../../../core/core.dart';

class AppModalSheet {
  AppModalSheet._();

  static void show(
    BuildContext context, {
    required String title,
    String? subtitle,
    required Widget child,
    bool showCloseButton = true,
    VoidCallback? onClose,
    bool enableDrag = true,
    bool isScrollable = true,
  }) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            hasSabGradient: false,
            topBarTitle: Text(
              title,
              style: AppTextStyles.h2,
            ),
            isTopBarLayerAlwaysVisible: true,
            leadingNavBarWidget: showCloseButton
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(modalSheetContext).pop();
                      onClose?.call();
                    },
                  )
                : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.screenPadding,
                DesignTokens.spacing8,
                DesignTokens.screenPadding,
                DesignTokens.spacing24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (subtitle != null) ...[
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing24),
                  ],
                  child,
                ],
              ),
            ),
          ),
        ];
      },
      modalTypeBuilder: (context) {
        return WoltModalType.bottomSheet();
      },
      onModalDismissedWithBarrierTap: () {
        Navigator.of(context).pop();
        onClose?.call();
      },
    );
  }

  static void showScrollable(
    BuildContext context, {
    required String title,
    String? subtitle,
    required Widget child,
    bool showCloseButton = true,
    VoidCallback? onClose,
  }) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            hasSabGradient: false,
            topBarTitle: Text(
              title,
              style: AppTextStyles.h2,
            ),
            isTopBarLayerAlwaysVisible: true,
            leadingNavBarWidget: showCloseButton
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(modalSheetContext).pop();
                      onClose?.call();
                    },
                  )
                : null,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.screenPadding,
                DesignTokens.spacing8,
                DesignTokens.screenPadding,
                DesignTokens.spacing24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (subtitle != null) ...[
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing24),
                  ],
                  child,
                ],
              ),
            ),
          ),
        ];
      },
      modalTypeBuilder: (context) {
        return WoltModalType.bottomSheet();
      },
      onModalDismissedWithBarrierTap: () {
        Navigator.of(context).pop();
        onClose?.call();
      },
    );
  }
}
