import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/motion_utils.dart';

/// Superficie estilo Apple Liquid Glass:
/// `BackdropFilter` con blur controlado + transparencia + borde de 1 px semitransparente + sombra suave.
/// Usado únicamente en elementos clave (header, barra sticky del CTA, cards destacadas) para mantener 60 fps.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final Color? tintColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool enableBlur;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = DesignTokens.radiusCard,
    this.blurSigma = DesignTokens.glassBlurSigma,
    this.tintColor,
    this.borderColor,
    this.onTap,
    this.semanticLabel,
    this.enableBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MotionUtils.reduceMotion(context);
    final effectiveSurface = tintColor ?? DesignTokens.glassSurface(isDark);
    final effectiveBorder = borderColor ?? DesignTokens.glassBorder(isDark);

    Widget container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 45 : 14),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );

    if (enableBlur && !reduceMotion && blurSigma > 0) {
      container = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: container,
        ),
      );
    }

    if (margin != null) {
      container = Padding(padding: margin!, child: container);
    }

    if (onTap != null) {
      return MotionUtils.pressable(
        onTap: onTap,
        pressedScale: 0.97,
        haptic: HapticType.lightImpact,
        semanticLabel: semanticLabel,
        borderRadius: BorderRadius.circular(borderRadius),
        child: container,
      );
    }

    return container;
  }
}

