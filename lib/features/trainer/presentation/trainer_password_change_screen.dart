import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/core.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/state/auth_controller.dart';
import '../data/trainer_api.dart';

class TrainerPasswordChangeScreen extends StatelessWidget {
  const TrainerPasswordChangeScreen({
    super.key,
    required this.authController,
    required this.trainerApi,
  });

  final AuthController authController;
  final TrainerApi trainerApi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Change Password',
        showBackButton: false,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: authController.logout,
            icon: const Icon(IconsaxPlusLinear.logout_1),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.screenPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.14),
                      borderRadius: DesignTokens.borderRadiusLarge,
                    ),
                    child: const Icon(
                      IconsaxPlusLinear.lock,
                      color: AppColors.primaryBlue,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Set your new password', style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  Text(
                    'Your temporary trainer password must be changed before you continue.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TrainerPasswordChangeForm(
                    trainerApi: trainerApi,
                    authController: authController,
                    onChanged: () async {
                      AppSnackBar.success(context, 'Password changed');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TrainerPasswordChangeSheet extends StatelessWidget {
  const TrainerPasswordChangeSheet({
    super.key,
    required this.authController,
    required this.trainerApi,
  });

  final AuthController authController;
  final TrainerApi trainerApi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: DesignTokens.screenPadding,
        right: DesignTokens.screenPadding,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Change Password', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text(
              'Use your current password, then choose a new one.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            TrainerPasswordChangeForm(
              trainerApi: trainerApi,
              authController: authController,
              onChanged: () async {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  AppSnackBar.success(context, 'Password changed');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TrainerPasswordChangeForm extends StatefulWidget {
  const TrainerPasswordChangeForm({
    super.key,
    required this.trainerApi,
    required this.authController,
    required this.onChanged,
  });

  final TrainerApi trainerApi;
  final AuthController authController;
  final Future<void> Function() onChanged;

  @override
  State<TrainerPasswordChangeForm> createState() =>
      _TrainerPasswordChangeFormState();
}

class _TrainerPasswordChangeFormState extends State<TrainerPasswordChangeForm> {
  final _current = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _current.dispose();
    _newPassword.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final validationError = _validate();
    if (validationError != null) {
      setState(() {
        _message = validationError;
        _isError = true;
      });
      return;
    }

    setState(() {
      _busy = true;
      _message = null;
    });

    try {
      await widget.trainerApi.changePassword(
        currentPassword: _current.text,
        newPassword: _newPassword.text,
      );
      await widget.authController.markPasswordChanged();
      await widget.onChanged();
      if (!mounted) return;
      setState(() {
        _message = 'Password changed successfully.';
        _isError = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _message = error.message;
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _validate() {
    if (_current.text.trim().isEmpty) {
      return 'Current password is required.';
    }
    if (_newPassword.text.length < 8) {
      return 'New password must be at least 8 characters.';
    }
    if (_newPassword.text != _confirm.text) {
      return 'New password and confirmation do not match.';
    }
    if (_current.text == _newPassword.text) {
      return 'Choose a password different from the current password.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _current,
          labelText: 'Current password',
          hintText: 'Temporary or current password',
          prefixIcon: IconsaxPlusLinear.lock,
          obscureText: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: _newPassword,
          labelText: 'New password',
          hintText: 'At least 8 characters',
          prefixIcon: IconsaxPlusLinear.lock,
          obscureText: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: _confirm,
          labelText: 'Confirm password',
          hintText: 'Repeat new password',
          prefixIcon: IconsaxPlusLinear.lock,
          obscureText: true,
          onSubmitted: (_) => _submit(),
        ),
        if (_message != null) ...[
          const SizedBox(height: 14),
          Text(
            _message!,
            style: AppTextStyles.bodySmall.copyWith(
              color: _isError ? AppColors.error : AppColors.success,
            ),
          ),
        ],
        const SizedBox(height: 20),
        CustomButton(
          text: 'Update Password',
          icon: IconsaxPlusLinear.tick_circle,
          isLoading: _busy,
          onPressed: _submit,
        ),
      ],
    );
  }
}
