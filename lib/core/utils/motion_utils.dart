import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MotionUtils {
  static const Duration defaultDuration = Duration(milliseconds: 260);
  static const Duration quickDuration = Duration(milliseconds: 140);
  static const Duration staggerInterval = Duration(milliseconds: 40);
  static const Curve appleCurve = Curves.easeInOutCubic;
  static const Curve defaultCurve = Curves.easeInOutCubic;

  /// Wraps a widget with a staggered fade + 10px slide-up entrance animation using Curves.easeInOutCubic.
  static Widget staggerEntrance(
    Widget child, {
    required int index,
    int maxStaggerIndex = 14,
    Duration duration = defaultDuration,
    Duration stagger = staggerInterval,
    Curve curve = appleCurve,
  }) {
    if (index >= maxStaggerIndex) {
      return child;
    }

    final delay = stagger * index;

    return child
        .animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .slideY(
          begin: 10.0 / 100.0, // subtle 10px slide
          end: 0.0,
          duration: duration,
          curve: curve,
        );
  }

  /// Apple HIG micro-interaction wrapper: scale down to 0.97 on press with Curves.easeInOutCubic.
  static Widget pressable({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    double pressedScale = 0.97,
    BorderRadius? borderRadius,
  }) {
    return _PressableScale(
      key: key,
      onTap: onTap,
      pressedScale: pressedScale,
      borderRadius: borderRadius,
      child: child,
    );
  }

  /// Smooth Apple HIG crossfade transition switcher for views, tabs and states.
  static Widget crossfade({
    required Widget child,
    required Key key,
    Duration duration = const Duration(milliseconds: 260),
  }) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: appleCurve,
      switchOutCurve: appleCurve,
      transitionBuilder: (w, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: appleCurve)),
          child: w,
        ),
      ),
      child: KeyedSubtree(key: key, child: child),
    );
  }
}

class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final BorderRadius? borderRadius;

  const _PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.borderRadius,
  });

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) {
      setState(() => _scale = widget.pressedScale);
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      setState(() => _scale = 1.0);
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      setState(() => _scale = 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaleWidget = AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: MotionUtils.appleCurve,
      child: widget.child,
    );

    if (widget.onTap == null) {
      return scaleWidget;
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: scaleWidget,
    );
  }
}
