import 'package:built_collection/built_collection.dart';
import 'package:get/get.dart';
import 'package:out_of_budget/db.dart';
import 'package:out_of_budget/models/account.dart';
import 'package:out_of_budget/models/transaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
class AccountsNotifier extends _$AccountsNotifier {
  @override
  Future<BuiltList<Account>> build() async {
    return await Get.find<AppDatabase>().getAccounts();
  }

  Future<void> addOrUpdate(Account account) async {
    await Get.find<AppDatabase>().addOrUpdateAccount(account);

    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id) async {
    await Get.find<AppDatabase>().deleteAccount(id);

    ref.invalidateSelf();
    await future;
  }
}

@riverpod
class TransactionsNotifier extends _$TransactionsNotifier {
  @override
  Future<BuiltList<MyTransaction>> build() async {
    return await Get.find<AppDatabase>().getAllTransactions();
  }

  Future<void> addOrUpdate(Iterable<MyTransaction> transactions) async {
    await Get.find<AppDatabase>().addOrUpdateTransactions(transactions);

    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id) async {
    await Get.find<AppDatabase>().deleteTransaction(id);

    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteByAccountId(String accountId) async {
    await Get.find<AppDatabase>().deleteTransactionsByAccountId(accountId);

    ref.invalidateSelf();
    await future;
  }
}

@riverpod
BuiltMap<String, (int, DateTime)> latestBalanceByAccount(
  LatestBalanceByAccountRef ref,
) {
  final transactions =
      ref.watch(transactionsNotifierProvider).value ?? BuiltList();

  return transactions.fold(
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
}

@riverpod
int totalBalance(TotalBalanceRef ref) {
  final balanceByAccount = ref.watch(latestBalanceByAccountProvider);
  return balanceByAccount.values.fold(0, (acc, item) => acc + item.$1);
}

@riverpod
Future<BuiltList<MyTransaction>> transactionsByAccountId(
  TransactionsByAccountIdRef ref,
  String accountId,
) async {
  ref.watch(transactionsNotifierProvider);
  return await Get.find<AppDatabase>().getTransactionsByAccnoutId(accountId);
}
