import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_card.dart';
import 'section_label.dart';

class KpiCard extends StatelessWidget {
  final String label;
  final num value;
  final String? prefix;
  final String? suffix;
  final AppCardVariant variant;
  final Widget? icon;
  final Duration duration;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.prefix,
    this.suffix,
    this.variant = AppCardVariant.white,
    this.icon,
    this.duration = const Duration(milliseconds: 600),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkCard = variant == AppCardVariant.dark;
    final textColor = isDarkCard ? AppColors.white : AppColors.darkCard;

    return AppCard(
      variant: variant,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SectionLabel(
                  label,
                  color: isDarkCard ? AppColors.darkSecondaryText : AppColors.textSecondaryLight,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                icon!,
              ],
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: value.toDouble()),
            duration: duration,
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              final formattedNumber = value is int
                  ? val.round().toString()
                  : val.toStringAsFixed(1);

              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '${prefix ?? ''}$formattedNumber${suffix ?? ''}',
                  style: AppTypography.display.copyWith(
                    color: textColor,
                    fontSize: 28,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
