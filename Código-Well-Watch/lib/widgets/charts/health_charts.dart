import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GlucosePressureLineChart extends StatelessWidget {
  final List<FlSpot> glucose;
  final List<FlSpot> pressure;
  const GlucosePressureLineChart({super.key, required this.glucose, required this.pressure});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 38)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.black.withValues(alpha: 0.08))),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: scheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              spots: glucose,
            ),
            LineChartBarData(
              isCurved: true,
              color: scheme.secondary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              spots: pressure,
            ),
          ],
        ),
      ),
    );
  }
}

class WeightBmiBarChart extends StatelessWidget {
  final List<double> weight;
  final List<double> bmi;
  const WeightBmiBarChart({super.key, required this.weight, required this.bmi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < weight.length && i < bmi.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 8,
          barRods: [
            BarChartRodData(toY: weight[i], color: scheme.primary, width: 10, borderRadius: const BorderRadius.all(Radius.circular(6))),
            BarChartRodData(toY: bmi[i], color: scheme.secondary, width: 10, borderRadius: const BorderRadius.all(Radius.circular(6))),
          ],
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 38)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.black.withValues(alpha: 0.08))),
          barGroups: groups,
        ),
      ),
    );
  }
}
