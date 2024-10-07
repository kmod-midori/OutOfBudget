import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:out_of_budget/models/account.dart';
import 'package:out_of_budget/pages/edit_account_page.dart';
import 'package:out_of_budget/providers.dart';
import 'package:out_of_budget/utils/date.dart';
import 'package:out_of_budget/utils/money.dart';
import 'package:out_of_budget/widgets/account_detail.dart';

class AccountsPage extends HookConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsNotifierProvider).value;

    if (accounts == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final balanceByAccount = ref.watch(latestBalanceByAccountProvider);
    final totalBalance = ref.watch(totalBalanceProvider);

    final TextTheme textTheme = Theme.of(context).textTheme;
    final orientation = MediaQuery.of(context).orientation;

    final selectedId = useState(accounts.firstOrNull?.id);
    final selectedAccount = selectedId.value != null
        ? accounts.firstWhere((a) => a.id == selectedId.value)
        : null;

    final accountsListView = ListView.builder(
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
          onTap: () {
            switch (orientation) {
              case Orientation.portrait:
                showModalBottomSheet<void>(
                  context: context,
                  builder: (context) => AccountSheet(
                    account: account,
                  ),
                );
                break;
              case Orientation.landscape:
                selectedId.value = account.id;
                break;
            }
          },
        );
      },
      itemCount: accounts.length + 1,
    );

    switch (orientation) {
      case Orientation.portrait:
        return accountsListView;
      case Orientation.landscape:
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: accountsListView,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 3,
              child: selectedAccount != null
                  ? AccountSheet(account: selectedAccount)
                  : const Center(child: Text("暂无账户")),
            ),
          ],
        );
    }
  }
}

class AccountCard extends HookWidget {
  final Account account;
  final int balanceInCents;
  final DateTime latestTxnDate;
  final void Function()? onTap;

  const AccountCard({
    super.key,
    required this.account,
    required this.balanceInCents,
    required this.latestTxnDate,
    this.onTap,
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
        onTap: onTap,
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

class AccountSheet extends HookConsumerWidget {
  final Account account;

  const AccountSheet({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      width: double.infinity,
      child: AccountDetail(account: account),
    );
  }
}
