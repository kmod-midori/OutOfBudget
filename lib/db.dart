import 'package:idb_shim/idb_browser.dart';
import 'package:out_of_budget/models/account.dart';
import 'package:out_of_budget/models/serializers.dart';

Future<AppDatabase> initDb() async {
  Database db = await getIdbFactory()!.open(
    "app.db",
    version: 1,
    onUpgradeNeeded: (VersionChangeEvent event) {
      Database db = event.database;

      db.createObjectStore("accounts", keyPath: "id");
      var txnsStore = db.createObjectStore("transactions", keyPath: "id");
      txnsStore.createIndex("date", "date");
    },
  );

  return AppDatabase(db);
}

class AppDatabase {
  Database db;

  AppDatabase(this.db);

  Future<List<Account>> getAccounts() async {
    var txn = db.transaction("accounts", idbModeReadOnly);
    var store = txn.objectStore("accounts");

    var accounts = <Account>[];

    var cursor = store.openCursor(autoAdvance: true);
    await for (var record in cursor) {
      accounts.add(
        standardSerializers.deserializeWith(Account.serializer, record.value)!,
      );
    }

    return accounts;
  }

  Future<Account?> getAccount(String id) async {
    var txn = db.transaction("accounts", idbModeReadOnly);
    var store = txn.objectStore("accounts");

    var record = await store.getObject(id);
    if (record == null) {
      return null;
    }

    return standardSerializers.deserializeWith(Account.serializer, record)!;
  }

  Future<void> addOrUpdateAccount(Account account) async {
    var txn = db.transaction("accounts", idbModeReadWrite);
    var store = txn.objectStore("accounts");

    await store.put(
      standardSerializers.serializeWith(Account.serializer, account)!,
    );
    await txn.completed;
  }

  Future<void> deleteAccount(String id) async {
    var txn = db.transaction("accounts", idbModeReadWrite);
    var store = txn.objectStore("accounts");

    await store.delete(id);
    await txn.completed;
  }
}
