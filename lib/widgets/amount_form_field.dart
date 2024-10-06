import 'package:flutter/material.dart';

class AmountFormField extends TextFormField {
  AmountFormField({
    super.key,
    required int initialValue,
    void Function(int? newValue)? onSaved,
    required String label,
  }) : super(
          initialValue: (initialValue / 100.0).toStringAsFixed(2),
          decoration: InputDecoration(
            label: Text(label),
          ),
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
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
            var intAmount = (parsed * 100.0).toInt();
            onSaved?.call(intAmount);
          },
        );
}
