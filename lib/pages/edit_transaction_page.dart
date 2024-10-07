import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nanoid/nanoid.dart';
import 'package:out_of_budget/db.dart';
import 'package:out_of_budget/models/transaction.dart';
import 'package:out_of_budget/providers.dart';
import 'package:out_of_budget/utils/date.dart';
import 'package:out_of_budget/widgets/amount_form_field.dart';

class EditTransactionPage extends HookConsumerWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String? id;

  final String? accountId;

  EditTransactionPage({super.key, this.id, this.accountId}) {
    assert(id == null || accountId == null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsNotifierProvider).value;
    if (accounts == null) {
      return const Center(child: CircularProgressIndicator());
    }

    var transaction = useTransaction(id);
    if (transaction.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }
    var transactionData = transaction.data;

    var initialSign = 1;
    var initialAmount = 0;
    if (transactionData != null) {
      initialAmount = transactionData.amount;
    }
    if (initialAmount < 0) {
      initialSign = -1;
    }
    var amountSign = useState(initialSign);

    var txnDate = useState(transactionData?.date ?? DateTime.now());
    var txnDateLocal = txnDate.value.toLocal();

    var txnBuilder = transactionData?.toBuilder() ?? MyTransactionBuilder();

    var body = Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              label: Text("账户"),
            ),
            items: accounts.map((account) {
              return DropdownMenuItem<String>(
                value: account.id,
                child: Text(account.name),
              );
            }).toList(),
            value: accountId ?? transactionData?.accountId,
            onSaved: (newValue) {
              txnBuilder.accountId = newValue!;
            },
            onChanged: (newValue) {},
            validator: (value) {
              if (value == null) {
                return '不可为空';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          AmountFormField(
            initialValue: transactionData?.amount ?? 0,
            label: "金额",
            onSaved: (newValue) {
              if (newValue != null) {
                txnBuilder.amount = newValue;
              }
            },
          ),
          const SizedBox(height: 16.0),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(
                label: Text("支出"),
                value: -1,
                icon: Icon(Icons.remove),
              ),
              ButtonSegment<int>(
                label: Text("收入"),
                value: 1,
                icon: Icon(Icons.add),
              ),
            ],
            selected: <int>{amountSign.value},
            onSelectionChanged: (Set<int> selected) {
              amountSign.value = selected.first;
            },
            showSelectedIcon: false,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton.icon(
            onPressed: () async {
              var value = await showDatePicker(
                context: context,
                initialDate: txnDate.value,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );

              if (value == null) {
                return;
              }

              txnDate.value = value;
            },
            label: Text(
              "${txnDateLocal.year}年${txnDateLocal.month}月${txnDateLocal.day}日",
            ),
            icon: const Icon(Icons.calendar_today),
          ),
          TextFormField(
            initialValue: transactionData?.description,
            decoration: const InputDecoration(
              label: Text("备注"),
            ),
            onSaved: (newValue) {
              txnBuilder.description = newValue ?? "";
            },
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(id == null ? "记录收支" : "编辑记录"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              _formKey.currentState!.save();

              txnBuilder.id ??= nanoid();
              txnBuilder.date ??= simplifyToDate(txnDate.value);

              var txn = txnBuilder.build();
              await ref
                  .read(transactionsNotifierProvider.notifier)
                  .addOrUpdate(txn);

              Get.back();
            },
          ),
        ],
      ),
      body: body,
    );
  }
}
