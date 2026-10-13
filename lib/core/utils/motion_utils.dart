import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MotionUtils {
  static const Duration defaultDuration = Duration(milliseconds: 250);
  static const Duration staggerInterval = Duration(milliseconds: 40);
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// Wraps a widget with a staggered fade + 12px slide-up entrance animation.
  /// Only animates up to [maxStaggerIndex] (default 10) items.
  static Widget staggerEntrance(
    Widget child, {
    required int index,
    int maxStaggerIndex = 10,
    Duration duration = defaultDuration,
    Duration stagger = staggerInterval,
    Curve curve = defaultCurve,
  }) {
    if (index >= maxStaggerIndex) {
      return child;
    }

    final delay = stagger * index;

    return child
        .animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .slideY(
          begin: 12.0 / 100.0, // subtle 12px slide
          end: 0.0,
          duration: duration,
          curve: curve,
        );
  }
}
