import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign textAlign;

  const SectionLabel(
    this.text, {
    super.key,
    this.color,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = color ?? (isDark ? AppColors.darkSecondaryText : AppColors.textSecondaryLight);

    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: AppTypography.sectionLabel.copyWith(color: defaultColor),
    );
  }
}
