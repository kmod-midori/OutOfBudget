import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nanoid/nanoid.dart';
import 'package:out_of_budget/db.dart';
import 'package:out_of_budget/models/account.dart';
import 'package:out_of_budget/models/transaction.dart';
import 'package:out_of_budget/providers.dart';
import 'package:out_of_budget/utils/date.dart';
import 'package:out_of_budget/widgets/amount_form_field.dart';

class EditAccountPage extends HookConsumerWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String? id;

  EditAccountPage({super.key, this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var account = useAccount(id);
    if (account.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }
    var accountData = account.data;

    var accountBuilder = accountData?.toBuilder() ?? AccountBuilder();
    var initialBalance = 0;

    var createDate = useState(DateTime.now());

    var body = Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          TextFormField(
            decoration: const InputDecoration(
              label: Text("账户名称"),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return '不可为空';
              }
              return null;
            },
            initialValue: accountData?.name,
            onSaved: (newValue) {
              accountBuilder.name = newValue!;
            },
          ),
          if (id == null) ...[
            AmountFormField(
              label: "初始余额",
              initialValue: 0,
              onSaved: (newValue) {
                initialBalance = newValue!;
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () async {
                var value = await showDatePicker(
                  context: context,
                  initialDate: createDate.value,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );

                if (value == null) {
                  return;
                }

                createDate.value = value;
              },
              label: Text(formatToLocalDate(createDate.value)),
              icon: const Icon(Icons.calendar_today),
            ),
          ]
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(id == null ? "添加账户" : "编辑账户"),
          actions: [
            if (id != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  var confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("删除账户"),
                        content: const Text("将删除账户及其所有记录，确认删除？"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text("取消"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text("删除"),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmed != true) {
                    return;
                  }

                  await ref
                      .read(accountsNotifierProvider.notifier)
                      .delete(accountBuilder.id!);
                  await ref
                      .read(transactionsNotifierProvider.notifier)
                      .deleteByAccountId(accountBuilder.id!);
                  Get.back();
                },
              ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                _formKey.currentState!.save();

                MyTransaction? createTxn;
                if (accountBuilder.id == null) {
                  accountBuilder.id = nanoid();
                  createTxn = MyTransaction(
                    (b) => b
                      ..id = nanoid()
                      ..accountId = accountBuilder.id
                      ..description = "账户创建"
                      ..date = simplifyToDate(createDate.value)
                      ..amount = initialBalance,
                  );
                }

                await ref
                    .read(accountsNotifierProvider.notifier)
                    .addOrUpdate(accountBuilder.build());
                if (createTxn != null) {
                  await ref
                      .read(transactionsNotifierProvider.notifier)
                      .addOrUpdate([createTxn]);
                }

                Get.back();
              },
            ),
          ]),
      body: body,
    );
  }
}
