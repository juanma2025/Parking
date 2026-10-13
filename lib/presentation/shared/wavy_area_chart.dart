import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_card.dart';
import 'section_label.dart';

class WavyAreaChart extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<double> values;
  final double height;

  const WavyAreaChart({
    super.key,
    required this.title,
    this.subtitle,
    required this.values,
    this.height = 160.0,
  });

  @override
  Widget build(BuildContext context) {
    final spots = values.isEmpty
        ? [const FlSpot(0, 0), const FlSpot(1, 0)]
        : values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();

    return AppCard(
      variant: AppCardVariant.amber, // #FEC775
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SectionLabel(
                title,
                color: AppColors.darkCard.withAlpha(200),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTypography.title.copyWith(
                    fontSize: 20,
                    color: AppColors.darkCard,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: height,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          spot.y.toStringAsFixed(0),
                          const TextStyle(
                            color: AppColors.darkCard,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.white,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.white,
                          strokeWidth: 2,
                          strokeColor: AppColors.secondary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.white.withAlpha(120),
                          AppColors.white.withAlpha(10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
