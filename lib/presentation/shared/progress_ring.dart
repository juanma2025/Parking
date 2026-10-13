import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProgressRing extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? trackColor;
  final Widget? center;
  final Duration duration;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 56.0,
    this.strokeWidth = 6.0,
    this.progressColor,
    this.trackColor,
    this.center,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveProgressColor = progressColor ?? AppColors.primary;
    final effectiveTrackColor = trackColor ?? effectiveProgressColor.withAlpha(40);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: value.clamp(0.0, 1.0)),
            duration: duration,
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              return CircularProgressIndicator(
                value: animatedValue,
                strokeWidth: strokeWidth,
                backgroundColor: effectiveTrackColor,
                valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
                strokeCap: StrokeCap.round,
              );
            },
          ),
          ?center,
        ],
      ),
    );
  }
}
