import 'package:flutter/material.dart';
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

    var body = Form(
      key: _formKey,
      child: ListView(
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
            onSaved: (newValue) {
              accountBuilder.name = newValue!;
            },
          ),
          if (id == null)
            AmountFormField(
              label: "初始余额",
              initialValue: 0,
              onSaved: (newValue) {
                initialBalance = newValue!;
              },
            ),
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
                  await ref
                      .read(accountsNotifierProvider.notifier)
                      .delete(accountBuilder.id!);
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
                      ..date = simplifyToDate(DateTime.now())
                      ..amount = initialBalance,
                  );
                }

                await ref
                    .read(accountsNotifierProvider.notifier)
                    .addOrUpdate(accountBuilder.build());
                if (createTxn != null) {
                  await ref
                      .read(transactionsNotifierProvider.notifier)
                      .addOrUpdate(createTxn);
                }

                Get.back();
              },
            ),
          ]),
      body: body,
    );
  }
}
