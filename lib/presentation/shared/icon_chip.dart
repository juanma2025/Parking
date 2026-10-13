import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class IconChip extends StatelessWidget {
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final VoidCallback? onTap;

  const IconChip({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.size = 44.0,
    this.iconSize = 22.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.white);
    final defaultIconColor = iconColor ?? (isDark ? AppColors.darkText : AppColors.darkCard);

    Widget chip = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: defaultBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: iconSize,
        color: defaultIconColor,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: chip,
      );
    }

    return chip;
  }
}
