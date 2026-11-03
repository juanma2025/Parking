import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_tokens.dart';

enum HapticType {
  none,
  selectionClick,
  lightImpact,
  mediumImpact,
  successNotification,
}

class MotionUtils {
  static const Duration defaultDuration = DesignTokens.durationNormal; // 320 ms
  static const Duration quickDuration = Duration(milliseconds: 90); // < 100 ms
  static const Duration staggerInterval = Duration(milliseconds: 45);
  static final Curve appleCurve = DesignTokens.springCurve;
  static final Curve defaultCurve = DesignTokens.springCurve;

  /// Verifica si el usuario activó "Reducir movimiento" en el sistema operativo.
  static bool reduceMotion(BuildContext context) {
    return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  /// Dispara feedback háptico nativo según el tipo de interacción Apple HIG.
  static void triggerHaptic(HapticType type) {
    switch (type) {
      case HapticType.none:
        break;
      case HapticType.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case HapticType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.successNotification:
        HapticFeedback.mediumImpact();
        Future<void>.delayed(const Duration(milliseconds: 60), () {
          HapticFeedback.selectionClick();
        });
        break;
    }
  }

  /// Entrada escalonada (staggered) con transición Fade + Scale (0.96 -> 1.0) y curva Spring.
  /// Si "Reducir movimiento" está activo, usa únicamente un fade simple sin scale ni slide.
  static Widget staggerEntrance(
    Widget child, {
    required int index,
    int maxStaggerIndex = 14,
    Duration duration = defaultDuration,
    Duration stagger = staggerInterval,
    Curve? curve,
  }) {
    if (index >= maxStaggerIndex) {
      return child;
    }

    return Builder(
      builder: (context) {
        final isReduced = reduceMotion(context);
        final effectiveCurve = curve ?? (isReduced ? Curves.easeOut : appleCurve);
        final delay = isReduced ? Duration.zero : stagger * index;

        if (isReduced) {
          return child.animate().fadeIn(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
              );
        }

        return child
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: effectiveCurve)
            .scaleXY(
              begin: 0.96,
              end: 1.0,
              duration: duration,
              curve: effectiveCurve,
            )
            .slideY(
              begin: 0.03,
              end: 0.0,
              duration: duration,
              curve: effectiveCurve,
            );
      },
    );
  }

  /// Wrapper de microinteracción Apple HIG:
  /// - Respuesta visual inmediata (< 100 ms) al tocar: scale a 0.97.
  /// - Retorno con simulación física Spring (`SpringSimulation`).
  /// - Feedback háptico integrado y soporte de `Semantics`.
  static Widget pressable({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    double pressedScale = 0.97,
    BorderRadius? borderRadius,
    HapticType haptic = HapticType.lightImpact,
    String? semanticLabel,
    bool isButton = true,
  }) {
    return _PressableSpringScale(
      key: key,
      onTap: onTap,
      pressedScale: pressedScale,
      borderRadius: borderRadius,
      haptic: haptic,
      semanticLabel: semanticLabel,
      isButton: isButton,
      child: child,
    );
  }

  /// Transición crossfade + scale suave con física Spring entre vistas o pestañas.
  static Widget crossfade({
    required Widget child,
    required Key key,
    Duration duration = DesignTokens.durationNormal,
  }) {
    return Builder(
      builder: (context) {
        final isReduced = reduceMotion(context);
        return AnimatedSwitcher(
          duration: isReduced ? const Duration(milliseconds: 160) : duration,
          switchInCurve: isReduced ? Curves.easeOut : appleCurve,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (w, animation) {
            if (isReduced) {
              return FadeTransition(opacity: animation, child: w);
            }
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: appleCurve),
                ),
                child: w,
              ),
            );
          },
          child: KeyedSubtree(key: key, child: child),
        );
      },
    );
  }
}

class _PressableSpringScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final BorderRadius? borderRadius;
  final HapticType haptic;
  final String? semanticLabel;
  final bool isButton;

  const _PressableSpringScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.borderRadius,
    this.haptic = HapticType.lightImpact,
    this.semanticLabel,
    this.isButton = true,
  });

  @override
  State<_PressableSpringScale> createState() => _PressableSpringScaleState();
}

class _PressableSpringScaleState extends State<_PressableSpringScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.85,
      upperBound: 1.05,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double target, {required bool isRelease}) {
    if (!mounted) return;
    final isReduced = MotionUtils.reduceMotion(context);
    if (isReduced) {
      _controller.value = 1.0;
      return;
    }

    if (!isRelease) {
      // Respuesta inmediata (< 100 ms) al presionar
      _controller.animateTo(
        target,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
      );
    } else {
      // Retorno con física Spring (SpringSimulation)
      final simulation = SpringSimulation(
        DesignTokens.springSnappyDesc,
        _controller.value,
        1.0,
        0.0,
      );
      _controller.animateWith(simulation);
    }
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) {
      _animateTo(widget.pressedScale, isRelease: false);
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      _animateTo(1.0, isRelease: true);
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _animateTo(1.0, isRelease: true);
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      MotionUtils.triggerHaptic(widget.haptic);
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _controller.value,
        child: child,
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    if (widget.semanticLabel != null || widget.onTap != null) {
      return Semantics(
        button: widget.isButton && widget.onTap != null,
        enabled: widget.onTap != null,
        label: widget.semanticLabel,
        child: content,
      );
    }

    return content;
  }
}
