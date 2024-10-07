import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:out_of_budget/models/account.dart';
import 'package:out_of_budget/pages/edit_account_page.dart';
import 'package:out_of_budget/pages/edit_transaction_page.dart';
import 'package:out_of_budget/providers.dart';
import 'package:out_of_budget/utils/date.dart';
import 'package:out_of_budget/utils/money.dart';
import 'package:out_of_budget/widgets/account_bar_chart.dart';

class AccountsPage extends HookConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsNotifierProvider).value;
    final transactions = ref.watch(transactionsNotifierProvider).value;

    if (accounts == null || transactions == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final balanceByAccount = ref.watch(latestBalanceByAccountProvider);
    final totalBalance = ref.watch(totalBalanceProvider);

    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text("总余额"),
            trailing: Text(
              formatFromCents(totalBalance),
              style: textTheme.titleLarge,
            ),
          );
        }

        index = index - 1;

        var account = accounts[index];
        var balanceData = balanceByAccount[account.id];

        return AccountCard(
          account: account,
          balanceInCents: balanceData?.$1 ?? 0,
          latestTxnDate: balanceData?.$2 ?? DateTime.now(),
        );
      },
      itemCount: accounts.length + 1,
    );
  }
}

class AccountCard extends HookWidget {
  final Account account;
  final int balanceInCents;
  final DateTime latestTxnDate;

  const AccountCard({
    super.key,
    required this.account,
    required this.balanceInCents,
    required this.latestTxnDate,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final balanceText = formatFromCents(balanceInCents);
    final latestTxnDateText = formatToLocalDate(latestTxnDate);

    var inner = ListTile(
      leading: const Icon(Icons.credit_card),
      title: Text(account.name),
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
