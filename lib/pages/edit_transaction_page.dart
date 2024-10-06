import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:nanoid/nanoid.dart';
import 'package:out_of_budget/db.dart';
import 'package:out_of_budget/models/transaction.dart';

class EditTransactionPage extends HookWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String? id;

  final String? accountId;

  EditTransactionPage({super.key, this.id, this.accountId}) {
    assert(id == null || accountId == null);
  }

  @override
  Widget build(BuildContext context) {
    var accounts = useAccounts();
    switch (accounts.connectionState) {
      case ConnectionState.waiting:
        return const Center(child: CircularProgressIndicator());
      case ConnectionState.done:
        break;
      default:
        return const Center(child: Text("Error"));
    }
    var accountsData = accounts.data!;

    var transaction = useTransaction(id);
    switch (transaction.connectionState) {
      case ConnectionState.waiting:
        return const Center(child: CircularProgressIndicator());
      case ConnectionState.done:
        break;
      default:
        return const Center(child: Text("Error"));
    }
    var transactionData = transaction.data;

    var amountController = useTextEditingController.fromValue(
      TextEditingValue(text: transactionData?.displayAmount ?? "0.00"),
    );
    var descriptionController = useTextEditingController.fromValue(
      TextEditingValue(text: transactionData?.description ?? ""),
    );

    var initialSign = 1;
    var initialAmount = 0;
    if (transactionData != null) {
      initialAmount = transactionData.amount;
    }
    if (initialAmount < 0) {
      initialSign = -1;
    }
    var amountSign = useState(initialSign);

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
            items: accountsData.map((account) {
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
          TextFormField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            decoration: const InputDecoration(
              label: Text("金额"),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return '不可为空';
              }
              var parsed = double.tryParse(value);
              if (parsed == null) {
                return '金额需为数字';
              }
              if (parsed == 0.0) {
                return '金额不可为0';
              }
              return null;
            },
            onSaved: (newValue) {
              var parsed = double.parse(newValue!);
              if (parsed > 0) {
                parsed = parsed * amountSign.value;
              }
              txnBuilder.amount = (parsed * 100.0).toInt();
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
          TextFormField(
            decoration: const InputDecoration(
              label: Text("备注"),
            ),
            controller: descriptionController,
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
              txnBuilder.date ??= DateTime.now().toUtc();

              var txn = txnBuilder.build();
              await Get.find<AppDatabase>().addOrUpdateTransaction(txn);

              Get.back();
            },
          ),
        ],
      ),
      body: body,
    );
  }
}
