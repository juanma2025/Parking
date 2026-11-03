import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/motion_utils.dart';

enum AppCardVariant {
  cream,
  amber,
  dark,
  white,
  elevated,
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
  final double borderRadius;
  final String? semanticLabel;
  final HapticType haptic;

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
    this.borderRadius = DesignTokens.radiusCard,
    this.semanticLabel,
    this.haptic = HapticType.lightImpact,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    BoxBorder? effectiveBorder = border;

    switch (variant) {
      case AppCardVariant.amber:
        backgroundColor = AppColors.secondary; // #FEC775
        effectiveBorder ??= Border.all(
          color: AppColors.primary.withAlpha(90),
          width: 1,
        );
        break;
      case AppCardVariant.dark:
        backgroundColor = isDark ? DesignTokens.darkSurface : AppColors.darkCard;
        effectiveBorder ??= Border.all(
          color: DesignTokens.darkOutline,
          width: 1,
        );
        break;
      case AppCardVariant.cream:
        backgroundColor =
            isDark ? DesignTokens.darkSurface : AppColors.lightBackground;
        effectiveBorder ??= Border.all(
          color: DesignTokens.outline(isDark),
          width: 1,
        );
        break;
      case AppCardVariant.elevated:
        backgroundColor = DesignTokens.surfaceElevated(isDark);
        effectiveBorder ??= Border.all(
          color: DesignTokens.outline(isDark),
          width: 1,
        );
        break;
      case AppCardVariant.white:
        // En Dark Mode nunca usa blanco fijo: usa gris oscuro con borde sutil 1px
        backgroundColor = DesignTokens.surface(isDark);
        effectiveBorder ??= Border.all(
          color: DesignTokens.outline(isDark),
          width: 1,
        );
        break;
    }

    final card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: effectiveBorder,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 35 : 10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return MotionUtils.pressable(
        onTap: onTap,
        pressedScale: 0.97,
        haptic: haptic,
        semanticLabel: semanticLabel,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }

    return card;
  }
}
