import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';

/// A mini sparkline chart showing a simulated 7-day exchange rate trend.
/// In a production app, historical data would come from a paid API endpoint;
/// here we use the current rate ± small noise to illustrate the widget's UI.
class RateChart extends StatelessWidget {
  final double currentRate;
  final String fromCode;
  final String toCode;

  const RateChart({
    super.key,
    required this.currentRate,
    required this.fromCode,
    required this.toCode,
  });

  List<FlSpot> _buildSpots() {
    // Simulate 7 days of rate variance (±3% random walk seeded by the rate)
    final seed = (currentRate * 100).toInt();
    const variance = [0.0, 0.012, -0.008, 0.021, -0.015, 0.007, 0.0];
    return List.generate(7, (i) {
      final factor = 1.0 + variance[i] + (seed % (i + 3)) * 0.0002;
      return FlSpot(i.toDouble(), currentRate * factor);
    });
  }

  @override
  Widget build(BuildContext context) {
    final spots = _buildSpots();
    final minY =
        spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) * 0.995;
    final maxY =
        spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.005;
    final isPositive = spots.last.y >= spots.first.y;
    final lineColor = isPositive ? kSuccess : kError;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '7-day trend',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: lineColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: lineColor,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      isPositive ? '+' : '',
                      style: TextStyle(
                          color: lineColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.4,
                    color: lineColor,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          lineColor.withValues(alpha: 0.25),
                          lineColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
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
