import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:out_of_budget/db.dart';
import 'package:out_of_budget/models/account.dart';
import 'package:out_of_budget/pages/edit_account_page.dart';
import 'package:out_of_budget/pages/edit_transaction_page.dart';
import 'package:out_of_budget/widgets/account_bar_chart.dart';

class AccountsPage extends HookWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = useAccounts();

    switch (accounts.connectionState) {
      case ConnectionState.waiting:
        return const Center(child: CircularProgressIndicator());
      case ConnectionState.done:
        break;
      default:
        return const Center(child: Text("Error"));
    }

    final accountsData = accounts.data!;

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        var account = accountsData[index];
        return AccountCard(account: account);
      },
      itemCount: accountsData.length,
    );
  }
}

class AccountCard extends HookWidget {
  final Account account;

  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final transactions = useTransactionsByAccountId(account.id);

    final balanceInCents = useMemoized(
      () => transactions.data?.fold<int>(0, (p, e) => p + e.amount),
      [transactions.data],
    );
    final balanceText = balanceInCents == null
        ? "-"
        : (balanceInCents / 100).toStringAsFixed(2);

    final latestTxn = transactions.data?.first;
    final latestTxnDateText = latestTxn == null
        ? "无记录"
        : "${latestTxn.date.year}年${latestTxn.date.month}月${latestTxn.date.day}日";

    var inner = ListTile(
      leading: const Icon(Icons.credit_card),
      title: Text("${account.name} (${account.id})"),
      subtitle: Text(latestTxnDateText),
      trailing: Text(
        balanceText,
        style: textTheme.titleLarge,
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: InkWell(
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (context) => AccountSheet(
              account: account,
            ),
          );
        },
        onLongPress: () {
          Get.to(() => EditAccountPage(id: account.id));
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: inner,
        ),
      ),
    );
  }
}

class AccountSheet extends HookWidget {
  final Account account;

  const AccountSheet({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 600,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(account.name, style: textTheme.titleLarge),
          const SizedBox(height: 8),
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
                  Get.back();
                  Get.to(() => EditTransactionPage(accountId: account.id));
                },
                label: const Text("记录收支"),
                icon: const Icon(Icons.add),
              )
            ],
          ),
          const SizedBox(height: 32),
          Expanded(child: AccountBarChart()),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
