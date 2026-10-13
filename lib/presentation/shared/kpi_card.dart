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

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.prefix,
    this.suffix,
    this.variant = AppCardVariant.white,
    this.icon,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    final isDarkCard = variant == AppCardVariant.dark;
    final textColor = isDarkCard ? AppColors.white : AppColors.darkCard;

    return AppCard(
      variant: variant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SectionLabel(
                label,
                color: isDarkCard ? AppColors.darkSecondaryText : AppColors.textSecondaryLight,
              ),
              ?icon,
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: value.toDouble()),
            duration: duration,
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              final formattedNumber = value is int
                  ? val.round().toString()
                  : val.toStringAsFixed(1);

              return Text(
                '${prefix ?? ''}$formattedNumber${suffix ?? ''}',
                style: AppTypography.display.copyWith(
                  color: textColor,
                  fontSize: 28,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
