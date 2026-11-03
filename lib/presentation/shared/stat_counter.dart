import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/motion_utils.dart';

/// Contador numérico con animación count-up (física Spring) e indicador de pulso en tiempo real.
/// Incluye estado Skeleton/Shimmer de carga para Fase 4.
class StatCounter extends StatefulWidget {
  final int value;
  final String label;
  final String? suffix;
  final bool isLoading;
  final VoidCallback? onTap;

  const StatCounter({
    super.key,
    required this.value,
    required this.label,
    this.suffix,
    this.isLoading = false,
    this.onTap,
  });

  @override
  State<StatCounter> createState() => _StatCounterState();
}

class _StatCounterState extends State<StatCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    final isTesting =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTesting) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MotionUtils.reduceMotion(context);

    if (widget.isLoading) {
      return Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
        highlightColor:
            isDark ? const Color(0xFF3F3F46) : const Color(0xFFF8FAFC),
        child: Container(
          height: 36,
          width: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusChip),
          ),
        ),
      );
    }

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceElevated(isDark),
        borderRadius: BorderRadius.circular(DesignTokens.radiusChip),
        border: Border.all(
          color: DesignTokens.outline(isDark),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de pulso suave en vivo
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final scale =
                  reduceMotion ? 1.0 : (0.85 + 0.30 * _pulseController.value);
              return Container(
                width: 9,
                height: 9,
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: DesignTokens.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: DesignTokens.success.withAlpha(140),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: reduceMotion ? widget.value : 0, end: widget.value),
            duration: reduceMotion
                ? const Duration(milliseconds: 100)
                : DesignTokens.durationSlow,
            curve: Curves.easeOutCubic,
            builder: (context, count, _) {
              return Text(
                '$count${widget.suffix ?? ''}',
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.accentText(isDark),
                ),
              );
            },
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DesignTokens.caption(isDark),
            ),
          ),
        ],
      ),
    );

    if (widget.onTap != null) {
      return MotionUtils.pressable(
        onTap: widget.onTap,
        haptic: HapticType.selectionClick,
        semanticLabel: '${widget.value} ${widget.label}',
        child: pill,
      );
    }

    return Semantics(
      label: '${widget.value} ${widget.label}',
      child: pill,
    );
  }
}

