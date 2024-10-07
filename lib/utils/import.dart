import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nanoid/nanoid.dart';
import 'package:out_of_budget/models/account.dart';
import 'package:out_of_budget/models/transaction.dart';
import 'package:out_of_budget/providers.dart';
import 'package:out_of_budget/utils/date.dart';
import 'package:out_of_budget/utils/money.dart';

Future<void> importPercentoCSV(PlatformFile file, WidgetRef ref) async {
  var csvString = await utf8.decodeStream(file.readStream!);

  var d = const FirstOccurrenceSettingsDetector(
    eols: ['\r\n', '\n'],
    textDelimiters: ['"', "'"],
  );
  var contents = const CsvToListConverter().convert(
    csvString,
    csvSettingsDetector: d,
    shouldParseNumbers: false,
  );

  var header = contents.first;
  var keyToIndex = <String, int>{};
  var indexToKey = <int, String>{};

  for (var i = 0; i < header.length; i++) {
    keyToIndex[header[i]] = i;
    indexToKey[i] = header[i];
  }

  var accounts = <String, List<MyTransactionBuilder>>{};

  for (var row in contents.skip(1)) {
    var accountName = row[keyToIndex['账户']!];
    var account = accounts.putIfAbsent(accountName, () => []);

    var builder = MyTransactionBuilder()
      ..id = nanoid()
      ..date = simplifyToDate(DateTime.parse(row[keyToIndex['时间']!]))
      ..amount = parseToCents(row[keyToIndex['增减金额']!])
      ..description = row[keyToIndex['备注']!];

    account.add(builder);
  }

  for (var entry in accounts.entries) {
    var accountName = "${entry.key}（导入）";
    var account = Account(
      (b) => b
        ..id = nanoid()
        ..name = accountName,
    );

    await ref.read(accountsNotifierProvider.notifier).addOrUpdate(account);

    var transactions = entry.value.map((b) {
      b.accountId = account.id;
      return b.build();
    }).toList();

    await ref
        .read(transactionsNotifierProvider.notifier)
        .addOrUpdate(transactions);
  }
}
