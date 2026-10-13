import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class StatusPill extends StatelessWidget {
  final String text;
  final Color? dotColor;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? leading;

  const StatusPill({
    super.key,
    required this.text,
    this.dotColor,
    this.backgroundColor,
    this.textColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = backgroundColor ?? (isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(12));
    final defaultText = textColor ?? (isDark ? AppColors.white : AppColors.darkCard);
    final effectiveDotColor = dotColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: defaultBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 4),
          ] else if (dotColor != null || dotColor == null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: effectiveDotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: AppTypography.caption.copyWith(
              color: defaultText,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
