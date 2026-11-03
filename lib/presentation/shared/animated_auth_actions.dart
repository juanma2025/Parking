import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/motion_utils.dart';

class AnimatedAuthActions extends StatelessWidget {
  const AnimatedAuthActions({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. TextButton discreto sin borde ni caja ("Iniciar sesión", >= 14 sp, área táctil >= 48x48 dp)
        Flexible(
          child: MotionUtils.pressable(
            haptic: HapticType.lightImpact,
            semanticLabel: 'Iniciar sesión en tu cuenta',
            onTap: () => context.push('/login'),
            borderRadius: BorderRadius.circular(DesignTokens.radiusChip),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: DesignTokens.minTouchTarget,
                minWidth: DesignTokens.minTouchTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Align(
                  alignment: Alignment.center,
                  widthFactor: 1.0,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        color: DesignTokens.onSurfaceVariant(isDark),
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 2. Único botón primario sólido ("Registro", >= 14 sp, área táctil >= 48x48 dp)
        Flexible(
          child: MotionUtils.pressable(
            haptic: HapticType.lightImpact,
            semanticLabel: 'Crear cuenta gratis',
            onTap: () => context.push('/register'),
            borderRadius: BorderRadius.circular(DesignTokens.radiusChip),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: DesignTokens.minTouchTarget,
                minWidth: DesignTokens.minTouchTarget,
              ),
              child: Center(
                widthFactor: 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.brandAccent,
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusChip),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Registro',
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        color: DesignTokens.onBrandAccent,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
