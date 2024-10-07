import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:out_of_budget/providers.dart';
import 'package:out_of_budget/widgets/account_bar_chart.dart';

class AnalyticsPage extends HookConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final transactions = ref.watch(transactionsNotifierProvider).value;
    final accounts = ref.watch(accountsNotifierProvider).value;
    final balanceByAccount = ref.watch(latestBalanceByAccountProvider);
    final totalBalance = ref.watch(totalBalanceProvider);

    if (transactions == null || accounts == null) {
      return const Center(child: CircularProgressIndicator());
    }

    var pieChartSections = useMemoized(
      () {
        var data = <PieChartSectionData>[];
        for (var account in accounts) {
          var balance = balanceByAccount[account.id]?.$1 ?? 0;
          if (balance == 0) {
            continue;
          }

          data.add(
            PieChartSectionData(
              value: (balance.toDouble() / totalBalance.toDouble()),
              title: account.name,
              radius: 180,
              color: theme.colorScheme.primary,
              titleStyle: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          );
        }

        return data;
      },
      [accounts, balanceByAccount, totalBalance],
    );

    var totalAmountChart = AccountBarChart(transactions: transactions);
    var accountPieChart = pieChartSections.isEmpty
        ? const Center(child: Text("暂无数据"))
        : PieChart(
            PieChartData(
              sections: pieChartSections,
              sectionsSpace: 1,
              centerSpaceRadius: double.infinity,
              titleSunbeamLayout: true,
            ),
          );

    var totalAmountView = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("总资产", style: theme.textTheme.titleMedium),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: totalAmountChart,
          ),
        ),
      ],
    );

    var accountPieView = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("分布", style: theme.textTheme.titleMedium),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: accountPieChart,
          ),
        ),
      ],
    );

    var orientation = MediaQuery.of(context).orientation;

    switch (orientation) {
      case Orientation.portrait:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: totalAmountView,
            ),
            Expanded(
              flex: 1,
              child: accountPieView,
            ),
          ],
        );
      case Orientation.landscape:
        return Row(
          children: [
            Expanded(
              flex: 1,
              child: totalAmountView,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 1,
              child: accountPieView,
            ),
          ],
        );
    }
  }
}
