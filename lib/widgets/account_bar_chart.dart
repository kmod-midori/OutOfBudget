import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';

class AccountBarChart extends HookWidget {
  const AccountBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentRange = useState(30);

    final endDate = DateTime(2024, 9, 30);

    const disabledTitles = AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    );

    var bottomTitles = AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 24,
        getTitlesWidget: (value, meta) {
          var date = endDate.add(Duration(days: (value - meta.max).toInt()));

          return SideTitleWidget(
            axisSide: meta.axisSide,
            child: Text("${date.month}/${date.day}"),
          );
        },
      ),
    );

    var leftTitles = AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        minIncluded: false,
        maxIncluded: false,
        reservedSize: 48,
        getTitlesWidget: (value, meta) {
          var intValue = value.toInt();

          var text = "$intValue";
          if (intValue >= 10000) {
            text = "${intValue / 1000}k";
          }

          return SideTitleWidget(
            axisSide: meta.axisSide,
            child: Text(text),
          );
        },
      ),
    );

    final tooltipTextStyle = TextStyle(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    final chartData = LineChartData(
      titlesData: FlTitlesData(
        topTitles: disabledTitles,
        bottomTitles: bottomTitles,
        rightTitles: leftTitles,
        leftTitles: leftTitles,
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => theme.colorScheme.primary,
          getTooltipItems: (touchedSpots) {
            return touchedSpots
                .map((spot) =>
                    LineTooltipItem(spot.y.toString(), tooltipTextStyle))
                .toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          color: theme.colorScheme.primary,
          spots: [
            FlSpot(1, 2),
            FlSpot(2, 2),
            FlSpot(3, 3),
            FlSpot(18, 114.51),
            FlSpot(65, 90 * 1000),
            FlSpot(180, 120 * 1000)
          ],
        )
      ],
    );

    return Column(
      children: [
        Expanded(child: LineChart(chartData)),
        const SizedBox(height: 16.0),
        SegmentedButton<int>(
          segments: const <ButtonSegment<int>>[
            ButtonSegment(
              value: 30,
              label: Text("30天"),
              icon: Icon(Icons.calendar_view_day),
            ),
            ButtonSegment(
              value: 180,
              label: Text("180天"),
              icon: Icon(Icons.calendar_view_week),
            ),
            ButtonSegment(
              value: 360,
              label: Text("360天"),
              icon: Icon(Icons.calendar_view_month),
            ),
            ButtonSegment(
              value: -1,
              label: Text("全部"),
              icon: Icon(Icons.calendar_today),
            )
          ],
          selected: <int>{currentRange.value},
          multiSelectionEnabled: false,
          onSelectionChanged: (items) {
            currentRange.value = items.first;
          },
        ),
      ],
    );
  }
}
