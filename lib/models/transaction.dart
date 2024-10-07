import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
part 'transaction.g.dart';

abstract class MyTransaction
    implements Built<MyTransaction, MyTransactionBuilder> {
  static Serializer<MyTransaction> get serializer => _$myTransactionSerializer;

  String get id;
  String get accountId;
  String get description;
  int get amount;
  DateTime get date;

  DateTime get dateLocal => date.toLocal();
  String get displayAmount => (amount / 100.0).toStringAsFixed(2);

  MyTransaction._();
  factory MyTransaction([void Function(MyTransactionBuilder) updates]) =
      _$MyTransaction;
}
