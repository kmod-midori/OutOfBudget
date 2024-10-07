import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:out_of_budget/utils/import.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.upload),
          title: const Text("导入数据（Percento CSV）"),
          subtitle: const Text("从 Percento 导入数据"),
          onTap: () async {
            var result = await FilePicker.platform.pickFiles(
              withReadStream: true,
              withData: false,
            );
            if (result == null) {
              return;
            }

            var file = result.files.single;

            try {
              await importPercentoCSV(file, ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("导入成功"),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("导入失败: $e"),
                  ),
                );
              }
              return;
            }
          },
        ),
        const Divider(height: 0),
      ],
    );
  }
}
