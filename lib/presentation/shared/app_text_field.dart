import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'section_label.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool showEyeToggle;
  final Color? fillColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? labelColor;
  final Color? iconColor;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.showEyeToggle = false,
    this.fillColor,
    this.textColor,
    this.hintColor,
    this.labelColor,
    this.iconColor,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveFillColor = widget.fillColor ?? (isDark ? AppColors.darkSurface : AppColors.white);
    final isFieldDark = effectiveFillColor.computeLuminance() < 0.35;

    final effectiveTextColor = widget.textColor ?? (isFieldDark ? AppColors.white : AppColors.darkCard);
    final effectiveHintColor = widget.hintColor ?? (isFieldDark ? Colors.white60 : AppColors.textSecondaryLight.withAlpha(150));
    final effectiveIconColor = widget.iconColor ?? (isFieldDark ? Colors.white70 : AppColors.textSecondaryLight);
    final effectiveLabelColor = widget.labelColor ?? (isDark ? AppColors.darkSecondaryText : AppColors.textSecondaryLight);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SectionLabel(widget.label!, color: effectiveLabelColor),
              if (widget.isPassword && !widget.showEyeToggle)
                GestureDetector(
                  onTap: () => setState(() => _obscureText = !_obscureText),
                  child: Text(
                    _obscureText ? 'MOSTRAR' : 'OCULTAR',
                    style: AppTypography.sectionLabel.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          cursorColor: AppColors.primary,
          style: AppTypography.body.copyWith(
            color: effectiveTextColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            fillColor: effectiveFillColor,
            hintText: widget.hintText,
            hintStyle: AppTypography.body.copyWith(
              color: effectiveHintColor,
            ),
            prefixIcon: widget.prefixIcon != null
                ? IconTheme(
                    data: IconThemeData(color: effectiveIconColor),
                    child: widget.prefixIcon!,
                  )
                : null,
            suffixIcon: widget.showEyeToggle && widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: effectiveIconColor,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : (widget.isPassword ? null : widget.suffixIcon),
          ),
        ),
      ],
    );
  }
}
