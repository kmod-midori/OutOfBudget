import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:out_of_budget/models/account.dart';
import 'package:out_of_budget/pages/edit_transaction_page.dart';
import 'package:out_of_budget/providers.dart';
import 'package:out_of_budget/utils/date.dart';
import 'package:out_of_budget/utils/money.dart';
import 'package:out_of_budget/widgets/account_bar_chart.dart';

class AccountDetail extends HookConsumerWidget {
  final Account account;

  const AccountDetail({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final tabController = useTabController(initialLength: 2);

    final transactions = ref
        .watch(transactionsByAccountIdProvider(
          account.id,
        ))
        .value;
    if (transactions == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Text(account.name, style: textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              label: const Text("更新余额"),
              icon: const Icon(Icons.edit),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => EditTransactionPage(accountId: account.id));
              },
              label: const Text("记录收支"),
              icon: const Icon(Icons.add),
            )
          ],
        ),
        const SizedBox(height: 32),
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: "图表"),
            Tab(text: "明细"),
          ],
        ),
        Expanded(
          child: TabBarView(controller: tabController, children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: AccountBarChart(transactions: transactions),
            ),
            ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                var txn = transactions[index];
                return ListTile(
                  title: Text(txn.description),
                  subtitle: Text(formatFromCents(txn.amount)),
                  trailing: Text(formatToLocalDate(txn.date)),
                  onTap: () {},
                );
              },
              itemCount: transactions.length,
            ),
          ]),
        ),
      ],
    );
  }
}
