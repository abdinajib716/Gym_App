import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/config/app_config.dart';
import '../../../core/core.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/auth_service.dart';
import '../state/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authController,
    required this.authService,
  });

  final AuthController authController;
  final AuthService authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    final ok = await widget.authController.login(
      identifier: _identifierController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _error = ok ? null : widget.authController.errorMessage);
  }

  Future<void> _openPasswordHelp() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PasswordHelpSheet(authService: widget.authService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      IconsaxPlusLinear.activity,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Gym App', style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in with your member or trainer account.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConfig.apiBaseUrl,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  CustomTextField(
                    controller: _identifierController,
                    labelText: 'Phone or email',
                    hintText: '061..., 25261..., or email',
                    prefixIcon: IconsaxPlusLinear.user,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    obscureText: true,
                    prefixIcon: IconsaxPlusLinear.lock,
                    onSubmitted: (_) => _login(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    _InlineMessage(message: _error!, isError: true),
                  ],
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Sign In',
                    icon: IconsaxPlusLinear.login_1,
                    isLoading: widget.authController.isBusy,
                    onPressed: _login,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _openPasswordHelp,
                    child: const Text('Forgot or reset password'),
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

class _PasswordHelpSheet extends StatefulWidget {
  const _PasswordHelpSheet({required this.authService});

  final AuthService authService;

  @override
  State<_PasswordHelpSheet> createState() => _PasswordHelpSheetState();
}

class _PasswordHelpSheetState extends State<_PasswordHelpSheet> {
  final _identifier = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _identifier.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _message = null;
    });

    try {
      if (_code.text.trim().isEmpty) {
        await widget.authService.forgotPassword(_identifier.text);
        _message = 'Reset code sent if this account exists.';
      } else {
        await widget.authService.resetPassword(
          identifier: _identifier.text,
          code: _code.text,
          password: _password.text,
        );
        _message = 'Password reset complete. You can sign in now.';
      }
      _isError = false;
    } on ApiException catch (error) {
      _message = error.message;
      _isError = true;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: DesignTokens.screenPadding,
        right: DesignTokens.screenPadding,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Password Help', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _identifier,
            labelText: 'Phone or email',
            hintText: 'Your mobile login',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _code,
            labelText: 'Reset code',
            hintText: 'Leave empty to request a code',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _password,
            labelText: 'New password',
            hintText: 'Required only when code is entered',
            obscureText: true,
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            _InlineMessage(message: _message!, isError: _isError),
          ],
          const SizedBox(height: 16),
          CustomButton(
            text: _code.text.trim().isEmpty
                ? 'Send Reset Code'
                : 'Reset Password',
            isLoading: _busy,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: AppTextStyles.bodySmall.copyWith(
        color: isError ? AppColors.error : AppColors.success,
      ),
    );
  }
}
