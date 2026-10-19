import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum PillButtonVariant {
  primary, // Orange #FBAB56
  amber,   // Amber #FEC775
  dark,    // Charcoal #222222
  outline, // Outlined
}

class PillButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final PillButtonVariant? variant;
  final Widget? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const PillButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = AppDimensions.buttonHeight,
  });

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _scale = 0.97);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _scale = 1.0);
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _scale = 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default variant: dark on light screens, orange on dark screens
    final effectiveVariant = widget.variant ??
        (isDark ? PillButtonVariant.primary : PillButtonVariant.dark);

    Color bgColor;
    Color fgColor;
    Border? border;

    switch (effectiveVariant) {
      case PillButtonVariant.primary:
        bgColor = AppColors.primary;
        fgColor = AppColors.darkCard;
        break;
      case PillButtonVariant.amber:
        bgColor = AppColors.secondary;
        fgColor = AppColors.darkCard;
        break;
      case PillButtonVariant.dark:
        bgColor = AppColors.darkCard;
        fgColor = AppColors.white;
        break;
      case PillButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = isDark ? AppColors.darkText : AppColors.darkCard;
        border = Border.all(color: fgColor, width: 1.5);
        break;
    }

    final buttonContent = widget.isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.text,
                      style: AppTypography.button.copyWith(color: fgColor),
                    ),
                  ),
                ),
              ],
            ),
          );

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            border: border,
          ),
          alignment: Alignment.center,
          child: buttonContent,
        ),
      ),
    );
  }
}
