import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// CustomTextField Widget
/// Reusable text input field with consistent styling
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final hintColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final fillColor = isDark
        ? AppColors.darkSurface
        : AppColors.backgroundLight;
    final disabledFillColor = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.55)
        : AppColors.backgroundLight.withValues(alpha: 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTextStyles.labelMedium.copyWith(color: textColor),
          ),
          const SizedBox(height: DesignTokens.spacing8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          textInputAction: widget.textInputAction,
          style: AppTextStyles.bodyMedium.copyWith(color: textColor),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: hintColor),
            errorText: widget.errorText,
            errorStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
            ),
            filled: true,
            fillColor: widget.enabled ? fillColor : disabledFillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing16,
              vertical: DesignTokens.spacing16,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: hintColor,
                    size: DesignTokens.iconSizeMedium,
                  )
                : null,
            suffixIcon: _buildSuffixIcon(),
            border: const OutlineInputBorder(
              borderRadius: DesignTokens.borderRadiusLarge,
              borderSide: BorderSide.none,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: DesignTokens.borderRadiusLarge,
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: DesignTokens.borderRadiusLarge,
              borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: DesignTokens.borderRadiusLarge,
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: DesignTokens.borderRadiusLarge,
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: const OutlineInputBorder(
              borderRadius: DesignTokens.borderRadiusLarge,
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    // Password visibility toggle
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? IconsaxPlusLinear.eye_slash : IconsaxPlusLinear.eye,
          color: iconColor,
          size: DesignTokens.iconSizeMedium,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: iconColor,
          size: DesignTokens.iconSizeMedium,
        ),
        onPressed: widget.onSuffixIconTap,
      );
    }

    return null;
  }
}

/// SearchTextField Widget
/// Specialized text field for search functionality
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onFilterTap;

  const SearchTextField({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: hintText,
      prefixIcon: IconsaxPlusLinear.search_normal_1,
      suffixIcon: onFilterTap != null ? IconsaxPlusLinear.filter : null,
      onSuffixIconTap: onFilterTap,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
    );
  }
}
