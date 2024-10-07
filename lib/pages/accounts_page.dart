import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:out_of_budget/db.dart';
import 'package:out_of_budget/models/account.dart';
import 'package:out_of_budget/pages/edit_account_page.dart';
import 'package:out_of_budget/pages/edit_transaction_page.dart';
import 'package:out_of_budget/utils/date.dart';
import 'package:out_of_budget/utils/money.dart';
import 'package:out_of_budget/widgets/account_bar_chart.dart';

class AccountsPage extends HookWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = useAccounts();
    final transactions = useAllTransactions();

    if (accounts.connectionState != ConnectionState.done ||
        transactions.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }

    final accountsData = accounts.data!;
    final transactionsData = transactions.data!;

    final balanceByAccount = useMemoized(() {
      return transactionsData.fold(
        MapBuilder<String, (int, DateTime)>(),
        (accs, txn) {
          var accountId = txn.accountId;
          var amount = txn.amount;
          var date = txn.date;

          var lastValue = accs[accountId];
          if (lastValue == null) {
            accs[accountId] = (amount, date);
          } else {
            accs[accountId] = (lastValue.$1 + amount, date);
          }

          return accs;
        },
      ).build();
    }, [accountsData, transactionsData]);
    final totalBalance = useMemoized(() {
      return balanceByAccount.values.fold(0, (acc, item) => acc + item.$1);
    }, [balanceByAccount]);

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        var account = accountsData[index];
        var balanceData = balanceByAccount[account.id];

        return AccountCard(
          account: account,
          balanceInCents: balanceData?.$1 ?? 0,
          latestTxnDate: balanceData?.$2 ?? DateTime.now(),
        );
      },
      itemCount: accountsData.length,
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
