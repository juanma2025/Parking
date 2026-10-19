import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/motion_utils.dart';

enum AppCardVariant {
  cream,
  amber,
  dark,
  white,
}

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final BoxBorder? border;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.white,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.onTap,
    this.width,
    this.height,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    switch (variant) {
      case AppCardVariant.amber:
        backgroundColor = AppColors.secondary; // #FEC775
        break;
      case AppCardVariant.dark:
        backgroundColor = isDark ? AppColors.darkSurface : AppColors.darkCard; // #222222
        break;
      case AppCardVariant.cream:
        backgroundColor = isDark ? AppColors.darkSurface : AppColors.lightBackground;
        break;
      case AppCardVariant.white:
        backgroundColor = isDark ? AppColors.darkSurface : AppColors.white;
        break;
    }

    final card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: border,
      ),
      child: child,
    );

    if (onTap != null) {
      return MotionUtils.pressable(
        onTap: onTap,
        pressedScale: 0.98,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: card,
      );
    }

    return card;
  }
}
