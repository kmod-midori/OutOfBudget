import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required Widget title,
  required Widget content,
  required Widget confirmLabel,
  required Widget cancelLabel,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: title,
        content: content,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: cancelLabel,
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: confirmLabel,
          ),
        ],
      );
    },
  );
}
