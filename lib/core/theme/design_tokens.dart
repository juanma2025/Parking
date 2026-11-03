import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Curva basada en simulación física Spring (Apple HIG).
/// Garantiza que `transformInternal(0.0) == 0.0` y `transformInternal(1.0) == 1.0`.
class AppleSpringCurve extends Curve {
  final SpringDescription spring;
  late final SpringSimulation _simulation;

  AppleSpringCurve({
    this.spring = const SpringDescription(
      mass: 1.0,
      stiffness: 300.0,
      damping: 24.0,
    ),
  }) {
    _simulation = SpringSimulation(spring, 0.0, 1.0, 0.0);
  }

  @override
  double transformInternal(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    // Evaluamos en un horizonte de 0.65s normalizado y aseguramos convergencia exacta en t=1
    final raw = _simulation.x(t * 0.65);
    final endError = 1.0 - _simulation.x(0.65);
    return (raw + endError * t).clamp(0.0, 1.08);
  }
}

/// Tokens centralizados de diseño para Parking Pasto (Apple HIG & Material 3).
class DesignTokens {
  DesignTokens._();

  // ===========================================================================
  // 1. COLORES DE MARCA Y SEMÁNTICOS (WCAG AA >= 4.5:1)
  // ===========================================================================
  static const Color brandAccent = Color(0xFFFBAB56); // Naranja de marca (botones/acentos sólidos)
  static const Color brandSecondary = Color(0xFFFEC775); // Ámbar cálido
  static const Color brandAccentOnLight = Color(0xFF9A3412); // Alto contraste (>= 6.2:1) sobre fondos claros
  static const Color brandAccentOnDark = Color(0xFFFEC775); // Alto contraste (>= 9.5:1) sobre fondos oscuros
  static const Color onBrandAccent = Color(0xFF18181B); // Texto oscuro sobre botón naranja sólido (contraste > 8.5:1)

  // Superficies Light Mode (diferenciadas por elevación)
  static const Color lightBackground = Color(0xFFFFF6EC);
  static const Color lightSurface = Color(0xFFFFFFFF); // Elevación 1 (Cards)
  static const Color lightSurfaceElevated = Color(0xFFF8FAFC); // Elevación 2 (Chips / Segmented)
  static const Color lightGlass = Color(0xD9FFFFFF); // 85% blanco translúcido
  static const Color lightOnSurface = Color(0xFF18181B); // Zinc-900 (Contraste > 15:1)
  static const Color lightOnSurfaceVariant = Color(0xFF475569); // Slate-600 (Contraste > 7:1)
  static const Color lightOutline = Color(0xFFE2E8F0); // Borde 1px sutil
  static const Color lightGlassBorder = Color(0x99FFFFFF);

  // Superficies Dark Mode (CERO cards blancas fijas; gris oscuro por elevación)
  static const Color darkBackground = Color(0xFF121214); // Base carbón profundo
  static const Color darkSurface = Color(0xFF1E1E22); // Elevación 1 (Cards en gris oscuro)
  static const Color darkSurfaceElevated = Color(0xFF28282E); // Elevación 2 (Chips / Controles)
  static const Color darkGlass = Color(0xBF1E1E22); // 75% gris oscuro translúcido
  static const Color darkOnSurface = Color(0xFFF4F4F5); // Zinc-100 (Contraste > 14:1)
  static const Color darkOnSurfaceVariant = Color(0xFFB4B4BE); // Contraste >= 6.4:1 (WCAG AA+)
  static const Color darkOutline = Color(0x26FFFFFF); // Borde 1px blanco al 15%
  static const Color darkGlassBorder = Color(0x2EFFFFFF); // Borde 1px blanco al 18%

  // Estados semánticos
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // Helpers semánticos según brillo activo
  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color surfaceElevated(bool isDark) =>
      isDark ? darkSurfaceElevated : lightSurfaceElevated;
  static Color glassSurface(bool isDark) => isDark ? darkGlass : lightGlass;
  static Color onSurface(bool isDark) => isDark ? darkOnSurface : lightOnSurface;
  static Color onSurfaceVariant(bool isDark) =>
      isDark ? darkOnSurfaceVariant : lightOnSurfaceVariant;
  static Color outline(bool isDark) => isDark ? darkOutline : lightOutline;
  static Color glassBorder(bool isDark) =>
      isDark ? darkGlassBorder : lightOutline;
  static Color accentText(bool isDark) =>
      isDark ? brandAccentOnDark : brandAccentOnLight;

  // ===========================================================================
  // 2. RADIOS DE ESQUINA (20-28 en cards, 14-16 en chips)
  // ===========================================================================
  static const double radiusCardSm = 20.0;
  static const double radiusCard = 24.0;
  static const double radiusCardLg = 28.0;
  static const double radiusChip = 15.0; // Rango 14-16
  static const double radiusButton = 18.0;
  static const double radiusPill = 999.0;

  // ===========================================================================
  // 3. ESPACIADOS Y ÁREAS TÁCTILES (>= 48x48 dp)
  // ===========================================================================
  static const double minTouchTarget = 48.0;
  static const double spacing2xs = 4.0;
  static const double spacingXs = 8.0;
  static const double spacingSm = 12.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 20.0;
  static const double spacingXl = 24.0;
  static const double spacing2xl = 32.0;

  // Blur controlado para Liquid Glass
  static const double glassBlurSigma = 16.0;

  // ===========================================================================
  // 4. DURACIONES Y CURVAS SPRING (250-400 ms)
  // ===========================================================================
  static const Duration durationFast = Duration(milliseconds: 250);
  static const Duration durationNormal = Duration(milliseconds: 320);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration pressDuration = Duration(milliseconds: 90); // < 100 ms respuesta inmediata

  static const SpringDescription springGentleDesc = SpringDescription(
    mass: 1.0,
    stiffness: 280.0,
    damping: 25.0,
  );

  static const SpringDescription springSnappyDesc = SpringDescription(
    mass: 1.0,
    stiffness: 360.0,
    damping: 23.0,
  );

  static final Curve springCurve = AppleSpringCurve(spring: springGentleDesc);
  static final Curve springSnappyCurve = AppleSpringCurve(spring: springSnappyDesc);

  // ===========================================================================
  // 5. TIPOGRAFÍA (SF Pro en iOS / Poppins en Android, mínimo >= 12 sp)
  // ===========================================================================
  static String get fontFamily {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      return '.SF Pro Text';
    }
    return 'Poppins';
  }

  static TextStyle largeTitle(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 26.0,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.6,
        color: onSurface(isDark),
      );

  static TextStyle headline(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 17.0,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
        color: onSurface(isDark),
      );

  static TextStyle body(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        height: 1.38,
        color: onSurfaceVariant(isDark),
      );

  static TextStyle bodyBold(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: onSurface(isDark),
      );

  static TextStyle caption(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.0, // Regla: mínimo 12 sp
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.1,
        color: onSurfaceVariant(isDark),
      );

  static TextStyle overline(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.0, // Regla: mínimo 12 sp
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: 0.8,
        color: accentText(isDark),
      );

  /// Limita el escalado de texto del sistema hasta 1.3x para accesibilidad sin romper el layout.
  static TextScaler clampedTextScaler(BuildContext context) {
    final currentScale = MediaQuery.textScalerOf(context).scale(1.0);
    final clamped = math.min(currentScale, 1.3);
    return TextScaler.linear(clamped);
  }
}

