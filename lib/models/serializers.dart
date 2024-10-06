import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'account.dart';
import 'transaction.dart';
import 'transaction_kind.dart';

part 'serializers.g.dart';

@SerializersFor([Account, MyTransaction, TransactionKind])
final Serializers serializers = _$serializers;
final standardSerializers = (serializers.toBuilder()
      ..addPlugin(
        StandardJsonPlugin(),
      ))
    .build();

Account deserializeAccount(Object json) =>
    standardSerializers.deserializeWith(Account.serializer, json)!;

Object serializeAccount(Account account) =>
    standardSerializers.serializeWith(Account.serializer, account)!;

MyTransaction deserializeTransaction(Object json) =>
    standardSerializers.deserializeWith(MyTransaction.serializer, json)!;

Object serializeTransaction(MyTransaction transaction) =>
    standardSerializers.serializeWith(MyTransaction.serializer, transaction)!;
