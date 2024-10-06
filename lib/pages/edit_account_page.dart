import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:nanoid/nanoid.dart';
import 'package:out_of_budget/db.dart';
import 'package:out_of_budget/models/account.dart';

class EditAccountPage extends HookWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String? id;

  EditAccountPage({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    var accountFuture = useMemoized(() {
      if (id == null) {
        return Future.value(null);
      }

      return Get.find<AppDatabase>().getAccount(id!);
    });
    var account = useFuture(accountFuture);

    switch (account.connectionState) {
      case ConnectionState.waiting:
        return const Center(child: CircularProgressIndicator());
      case ConnectionState.done:
        break;
      default:
        return const Center(child: Text("Error"));
    }

    var accountData = account.data;

    var nameController = useTextEditingController.fromValue(
      TextEditingValue(text: accountData?.name ?? ""),
    );

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
            controller: nameController,
          ),
          if (id == null)
            TextFormField(
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                label: Text("初始余额"),
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return '不可为空';
                }
                return null;
              },
              initialValue: "0.0",
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
                  await Get.find<AppDatabase>().deleteAccount(id!);
                  Get.back();
                },
              ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                Account account;

                if (accountData == null) {
                  account = Account(
                    (b) => b
                      ..id = nanoid()
                      ..name = nameController.text,
                  );
                } else {
                  account = accountData.rebuild(
                    (b) => b..name = nameController.text,
                  );
                }

                await Get.find<AppDatabase>().addOrUpdateAccount(account);
                Get.back();
              },
            ),
          ]),
      body: body,
    );
  }
}
