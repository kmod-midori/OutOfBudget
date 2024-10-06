import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transaction_kind.g.dart';

class TransactionKind extends EnumClass {
  static Serializer<TransactionKind> get serializer =>
      _$transactionKindSerializer;

  static const TransactionKind accountCreation = _$accountCreation;
  static const TransactionKind normal = _$normal;

  const TransactionKind._(super.name);

  static BuiltSet<TransactionKind> get values => _$valuesTransactionKind;
  static TransactionKind valueOf(String name) => _$valueOfTransactionKind(name);
}
