import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transaction.g.dart';

abstract class Transaction implements Built<Transaction, TransactionBuilder> {
  static Serializer<Transaction> get serializer => _$transactionSerializer;

  String get id;
  String get accountId;
  String get description;
  int get amount;
  DateTime get date;

  Transaction._();
  factory Transaction([void Function(TransactionBuilder) updates]) =
      _$Transaction;
}
