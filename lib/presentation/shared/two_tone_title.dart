import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class TwoToneTitle extends StatelessWidget {
  final String text;
  final String? highlightText;
  final TextStyle? baseStyle;
  final Color? normalColor;
  final Color? highlightColor;
  final TextAlign textAlign;

  const TwoToneTitle({
    super.key,
    required this.text,
    this.highlightText,
    this.baseStyle,
    this.normalColor,
    this.highlightColor,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultNormalColor = normalColor ?? (isDark ? AppColors.darkText : AppColors.darkCard);
    final defaultHighlightColor = highlightColor ?? (isDark ? AppColors.darkAccent : AppColors.primary);
    final style = baseStyle ?? AppTypography.display;

    String mainPart;
    String accentPart;

    if (highlightText != null && highlightText!.isNotEmpty) {
      mainPart = text;
      accentPart = highlightText!;
    } else {
      // Split and highlight the last word
      final words = text.trim().split(RegExp(r'\s+'));
      if (words.length > 1) {
        accentPart = words.last;
        mainPart = '${words.sublist(0, words.length - 1).join(' ')} ';
      } else {
        mainPart = '';
        accentPart = text;
      }
    }

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: style.copyWith(color: defaultNormalColor),
        children: [
          if (mainPart.isNotEmpty) TextSpan(text: mainPart),
          TextSpan(
            text: accentPart,
            style: style.copyWith(color: defaultHighlightColor),
          ),
        ],
      ),
    );
  }
}
