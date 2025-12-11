import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../../../core/core.dart';

enum AlertType { success, error, warning, info, question }

class AppAlertDialog {
  AppAlertDialog._();

  static void show(
    BuildContext context, {
    required AlertType type,
    required String title,
    String? message,
    String okText = 'OK',
    VoidCallback? onOk,
    bool dismissOnTouchOutside = true,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: _getDialogType(type),
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkText: okText,
      btnOkColor: _getColor(type),
      btnOkOnPress: onOk ?? () {},
      dismissOnTouchOutside: dismissOnTouchOutside,
      titleTextStyle: AppTextStyles.h2,
      descTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      buttonsBorderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      padding: const EdgeInsets.all(DesignTokens.spacing16),
    ).show();
  }

  static void confirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool dismissOnTouchOutside = true,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkText: confirmText,
      btnCancelText: cancelText,
      btnOkColor: AppColors.primaryBlue,
      btnCancelColor: AppColors.textSecondary,
      btnOkOnPress: onConfirm,
      btnCancelOnPress: onCancel ?? () {},
      dismissOnTouchOutside: dismissOnTouchOutside,
      titleTextStyle: AppTextStyles.h2,
      descTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      buttonsBorderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      padding: const EdgeInsets.all(DesignTokens.spacing16),
    ).show();
  }

  static void success(
    BuildContext context, {
    required String title,
    String? message,
    VoidCallback? onOk,
  }) {
    show(
      context,
      type: AlertType.success,
      title: title,
      message: message,
      onOk: onOk,
    );
  }

  static void error(
    BuildContext context, {
    required String title,
    String? message,
    VoidCallback? onOk,
  }) {
    show(
      context,
      type: AlertType.error,
      title: title,
      message: message,
      onOk: onOk,
    );
  }

  static DialogType _getDialogType(AlertType type) {
    switch (type) {
      case AlertType.success:
        return DialogType.success;
      case AlertType.error:
        return DialogType.error;
      case AlertType.warning:
        return DialogType.warning;
      case AlertType.info:
        return DialogType.info;
      case AlertType.question:
        return DialogType.question;
    }
  }

  static Color _getColor(AlertType type) {
    switch (type) {
      case AlertType.success:
        return AppColors.success;
      case AlertType.error:
        return AppColors.error;
      case AlertType.warning:
        return AppColors.warning;
      case AlertType.info:
        return AppColors.primaryBlue;
      case AlertType.question:
        return AppColors.primaryBlue;
    }
  }
}
