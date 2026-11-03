import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/motion_utils.dart';

/// Botón CTA primario de alto contraste (Apple HIG):
/// - Color de acento sólido (`#FBAB56`) con texto oscuro (`#18181B`, contraste > 8.5:1 WCAG AAA).
/// - Área táctil mínima >= 48x48 dp (54 dp por defecto).
/// - Respuesta inmediata press scale a 0.97 con retorno Spring y `HapticFeedback.mediumImpact()`.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final String? badgeText;
  final String? heroTag;
  final String? semanticLabel;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.badgeText,
    this.heroTag,
    this.semanticLabel,
    this.height = 54.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonBody = Container(
      height: height < DesignTokens.minTouchTarget
          ? DesignTokens.minTouchTarget
          : height,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: DesignTokens.brandAccent,
        borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
        border: Border.all(
          color: DesignTokens.brandSecondary.withAlpha(180),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.brandAccent.withAlpha(95),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: DesignTokens.onBrandAccent,
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: DesignTokens.onBrandAccent,
              ),
            ),
          ),
          if (badgeText != null) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: DesignTokens.onBrandAccent.withAlpha(24),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeText!,
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.onBrandAccent,
                ),
              ),
            ),
          ],
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            Icon(
              trailingIcon,
              size: 18,
              color: DesignTokens.onBrandAccent,
            ),
          ],
        ],
      ),
    );

    if (heroTag != null) {
      buttonBody = Hero(
        tag: heroTag!,
        child: Material(
          color: Colors.transparent,
          child: buttonBody,
        ),
      );
    }

    return MotionUtils.pressable(
      onTap: onPressed,
      pressedScale: 0.97,
      haptic: HapticType.mediumImpact,
      semanticLabel: semanticLabel ?? label,
      borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
      child: buttonBody,
    );
  }
}

