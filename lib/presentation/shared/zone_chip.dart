import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/motion_utils.dart';
import '../../data/datasources/pasto_landmarks_data.dart';

/// Chip interactivo de zona de San Juan de Pasto (Fase 1-4):
/// - Esquinas redondeadas 15 px (rango 14-16).
/// - Área táctil mínima >= 48 dp de altura.
/// - Efecto `Hero` compartido con el mapa explorador de la zona.
/// - Feedback háptico `selectionClick` + press scale 0.97 con retorno Spring.
/// - Superficie adaptativa Light/Dark con contraste WCAG AA (>= 4.5:1).
class ZoneChip extends StatelessWidget {
  final Landmark landmark;
  final VoidCallback onTap;
  final bool isSelected;

  const ZoneChip({
    super.key,
    required this.landmark,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMall = landmark.category == LandmarkCategory.shoppingMall;
    final totalSpaces = landmark.nearbyParkingLots.fold<int>(
      0,
      (sum, lot) => sum + lot.totalSpaces,
    );

    final Color iconColor = isMall
        ? (isDark ? DesignTokens.brandSecondary : DesignTokens.brandAccentOnLight)
        : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626));

    final chipContent = Container(
      constraints: const BoxConstraints(
        minHeight: DesignTokens.minTouchTarget, // >= 48 dp
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: isSelected
            ? DesignTokens.brandAccent.withAlpha(isDark ? 45 : 35)
            : DesignTokens.surface(isDark),
        borderRadius: BorderRadius.circular(DesignTokens.radiusChip),
        border: Border.all(
          color: isSelected
              ? DesignTokens.brandAccent
              : DesignTokens.outline(isDark),
          width: isSelected ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            landmark.icon,
            size: 17,
            color: iconColor,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              landmark.shortName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
                color: DesignTokens.onSurface(isDark),
              ),
            ),
          ),
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: DesignTokens.surfaceElevated(isDark),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: DesignTokens.outline(isDark),
                width: 0.8,
              ),
            ),
            child: Text(
              '$totalSpaces cupos',
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 12.0, // Regla: mínimo 12 sp
                fontWeight: FontWeight.w700,
                color: DesignTokens.accentText(isDark),
              ),
            ),
          ),
        ],
      ),
    );

    return MotionUtils.pressable(
      onTap: onTap,
      pressedScale: 0.97,
      haptic: HapticType.selectionClick,
      semanticLabel:
          'Ver mapa en zona ${landmark.name}, $totalSpaces cupos disponibles',
      borderRadius: BorderRadius.circular(DesignTokens.radiusChip),
      child: Hero(
        tag: 'zone-chip-hero-${landmark.id}',
        child: Material(
          color: Colors.transparent,
          child: chipContent,
        ),
      ),
    );
  }
}

