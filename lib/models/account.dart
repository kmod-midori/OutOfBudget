import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'account.g.dart';

abstract class Account implements Built<Account, AccountBuilder> {
  static Serializer<Account> get serializer => _$accountSerializer;

  String get id;
  String get name;

  Account._();
  factory Account([void Function(AccountBuilder) updates]) = _$Account;
}
