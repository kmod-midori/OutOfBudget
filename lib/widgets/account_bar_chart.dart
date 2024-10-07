import 'package:built_collection/built_collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:out_of_budget/models/transaction.dart';
import 'package:out_of_budget/utils/date.dart';

class AccountBarChart extends HookConsumerWidget {
  final BuiltList<MyTransaction> transactions;

  const AccountBarChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final currentRange = useState(30);

    final dateEnd = simplifyToDate(DateTime.now());
    final dateStart = currentRange.value == -1
        ? transactions.firstOrNull?.date ?? dateEnd
        : dateEnd.subtract(Duration(days: currentRange.value));

    final spots = useMemoized(() {
      var currentSum = 0;
      var spots = <int, int>{};

      for (var txn in transactions) {
        currentSum += txn.amount;

        var daysFromStart = txn.date.difference(dateStart).inDays;
        if (daysFromStart > currentRange.value && currentRange.value != -1) {
          continue;
        }

        if (daysFromStart < 0) {
          daysFromStart = 0;
        }

        spots[daysFromStart] = currentSum ~/ 100;
      }

      var lastDayOffset = dateEnd.difference(dateStart).inDays;
      spots[lastDayOffset] = currentSum ~/ 100;

      return spots;
    }, [transactions, dateStart, dateEnd]);

    const disabledTitles = AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    );

    var bottomTitles = AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        minIncluded: false,
        maxIncluded: false,
        reservedSize: 24,
        getTitlesWidget: (value, meta) {
          var date = dateStart.add(Duration(days: (value).toInt())).toLocal();

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

    final bar = LineChartBarData(
      color: theme.colorScheme.primary,
      spots: spots.entries
          .map((entry) => FlSpot(
                entry.key.toDouble(),
                entry.value.toDouble(),
              ))
          .toList(),
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
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipColor: (touchedSpot) => theme.colorScheme.primary,
          getTooltipItems: (touchedSpots) {
            var ret = <LineTooltipItem>[];

            for (var spot in touchedSpots) {
              var date = formatToLocalDate(
                dateStart.add(Duration(days: spot.x.toInt())),
              );

              ret.add(LineTooltipItem(
                "$date\n${spot.y.toInt()}",
                tooltipTextStyle,
              ));
            }

            return ret;
          },
        ),
      ),
      lineBarsData: [bar],
      minY: 0.0,
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
