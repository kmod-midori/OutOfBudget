import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:out_of_budget/models/account.dart';
import 'package:out_of_budget/models/serializers.dart';
import 'package:out_of_budget/models/transaction.dart';

Future<AppDatabase> initDb() async {
  Database db = await getIdbFactory()!.open(
    "app.db",
    version: 1,
    onUpgradeNeeded: (VersionChangeEvent event) {
      Database db = event.database;

      db.createObjectStore("accounts", keyPath: "id");
      var txnsStore = db.createObjectStore("transactions", keyPath: "id");
      txnsStore.createIndex("date", "date");
      txnsStore.createIndex("accountId", "accountId");
    },
  );

  return AppDatabase(db);
}

class AppDatabase {
  final _accountsStoreName = "accounts";
  final _transactionsStoreName = "transactions";

  Database db;

  AppDatabase(this.db);

  Future<BuiltList<Account>> getAccounts() async {
    var txn = db.transaction(_accountsStoreName, idbModeReadOnly);
    var store = txn.objectStore(_accountsStoreName);

    var accounts = ListBuilder<Account>();

    var cursor = store.openCursor(autoAdvance: true);
    await for (var record in cursor) {
      accounts.add(deserializeAccount(record.value));
    }

    return accounts.build();
  }

  Future<Account?> getAccount(String id) async {
    var txn = db.transaction(_accountsStoreName, idbModeReadOnly);
    var store = txn.objectStore(_accountsStoreName);

    var record = await store.getObject(id);
    if (record == null) {
      return null;
    }

    return deserializeAccount(record);
  }

  Future<void> addOrUpdateAccount(Account account) async {
    var txn = db.transaction(_accountsStoreName, idbModeReadWrite);
    var store = txn.objectStore(_accountsStoreName);

    await store.put(serializeAccount(account));
    await txn.completed;
  }

  Future<void> deleteAccount(String id) async {
    var txn = db.transactionList([
      _accountsStoreName,
      _transactionsStoreName,
    ], idbModeReadWrite);

    await txn.objectStore(_accountsStoreName).delete(id);

    var txnStore = txn.objectStore(_transactionsStoreName);
    var cursor = txnStore.index("accountId").openCursor(
          key: id,
          autoAdvance: true,
        );
    await for (var record in cursor) {
      await txnStore.delete(record.primaryKey);
    }

    await txn.completed;
  }

  Future<MyTransaction?> getTransaction(String id) async {
    var txn = db.transaction(_transactionsStoreName, idbModeReadOnly);
    var store = txn.objectStore(_transactionsStoreName);

    var record = await store.getObject(id);
    if (record == null) {
      return null;
    }

    return deserializeTransaction(record);
  }

  Future<void> addOrUpdateTransaction(MyTransaction myTxn) async {
    var txn = db.transaction("transactions", idbModeReadWrite);
    var store = txn.objectStore("transactions");

    await store.put(serializeTransaction(myTxn));
    await txn.completed;
  }

  Future<void> deleteTransaction(String id) async {
    var txn = db.transaction("transactions", idbModeReadWrite);
    var store = txn.objectStore("transactions");

    await store.delete(id);
    await txn.completed;
  }

  Future<List<MyTransaction>> getTransactionsByAccnoutId(
    String accountId,
  ) async {
    var txn = db.transaction("transactions", idbModeReadOnly);
    var store = txn.objectStore("transactions");

    var index = store.index("accountId");
    var cursor = index.openCursor(key: accountId, autoAdvance: true);

    var txns = <MyTransaction>[];
    await for (var record in cursor) {
      txns.add(deserializeTransaction(record.value));
    }
    txns.sort((a, b) => b.date.compareTo(a.date));

    return txns;
  }

  Future<List<MyTransaction>> getAllTransactions() async {
    var txn = db.transaction("transactions", idbModeReadOnly);
    var store = txn.objectStore("transactions");

    var index = store.index("date");
    var cursor = index.openCursor(autoAdvance: true, direction: "prev");

    var txns = <MyTransaction>[];
    await for (var record in cursor) {
      txns.add(deserializeTransaction(record.value));
    }

    return txns;
  }

  Future<List<MyTransaction>> getTransactionsByDateRange(
    String? accountId,
    DateTime start,
    DateTime end,
  ) async {
    var txn = db.transaction("transactions", idbModeReadOnly);
    var store = txn.objectStore("transactions");

    var index = store.index("date");
    var cursor = index.openCursor(
      autoAdvance: true,
      range: KeyRange.bound(
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ),
      direction: "prev",
    );

    var txns = <MyTransaction>[];
    await for (var record in cursor) {
      var txn = deserializeTransaction(record.value);

      if (accountId == null || txn.accountId == accountId) {
        txns.add(txn);
      }
    }

    return txns;
  }
}

AsyncSnapshot<BuiltList<Account>> useAccounts() {
  final accountsFuture = useMemoized(
    () => Get.find<AppDatabase>().getAccounts(),
  );

  return useFuture(accountsFuture);
}

AsyncSnapshot<Account?> useAccount(String? id) {
  final accountFuture = useMemoized(
    () => id == null
        ? Future.value(null)
        : Get.find<AppDatabase>().getAccount(id),
    [id],
  );

  return useFuture(accountFuture);
}

AsyncSnapshot<MyTransaction?> useTransaction(String? id) {
  final txnFuture = useMemoized(
    () => id == null
        ? Future.value(null)
        : Get.find<AppDatabase>().getTransaction(id),
    [id],
  );

  return useFuture(txnFuture);
}
