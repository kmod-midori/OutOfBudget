import 'package:flutter/material.dart';
import 'package:out_of_budget/utils/money.dart';

class AmountFormField extends TextFormField {
  AmountFormField({
    super.key,
    required int initialValue,
    void Function(int? newValue)? onSaved,
    required String label,
    bool allowZero = false,
  }) : super(
          initialValue: formatFromCents(initialValue, signMode: SignMode.never),
          decoration: InputDecoration(
            label: Text(label),
            border: const OutlineInputBorder(),
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
            if (parsed == 0.0 && !allowZero) {
              return '金额不可为0';
            }
            if (parsed < 0.0) {
              return '金额不可为负数';
            }
            return null;
          },
          onSaved: (newValue) {
            onSaved?.call(parseToCents(newValue!));
          },
        );
}
