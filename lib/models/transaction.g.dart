// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Transaction> _$transactionSerializer = new _$TransactionSerializer();

class _$TransactionSerializer implements StructuredSerializer<Transaction> {
  @override
  final Iterable<Type> types = const [Transaction, _$Transaction];
  @override
  final String wireName = 'Transaction';

  @override
  Iterable<Object?> serialize(Serializers serializers, Transaction object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'accountId',
      serializers.serialize(object.accountId,
          specifiedType: const FullType(String)),
      'description',
      serializers.serialize(object.description,
          specifiedType: const FullType(String)),
      'amount',
      serializers.serialize(object.amount, specifiedType: const FullType(int)),
      'date',
      serializers.serialize(object.date,
          specifiedType: const FullType(DateTime)),
    ];

    return result;
  }

  @override
  Transaction deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TransactionBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'accountId':
          result.accountId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'description':
          result.description = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'amount':
          result.amount = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'date':
          result.date = serializers.deserialize(value,
              specifiedType: const FullType(DateTime))! as DateTime;
          break;
      }
    }

    return result.build();
  }
}

class _$Transaction extends Transaction {
  @override
  final String id;
  @override
  final String accountId;
  @override
  final String description;
  @override
  final int amount;
  @override
  final DateTime date;

  factory _$Transaction([void Function(TransactionBuilder)? updates]) =>
      (new TransactionBuilder()..update(updates))._build();

  _$Transaction._(
      {required this.id,
      required this.accountId,
      required this.description,
      required this.amount,
      required this.date})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'Transaction', 'id');
    BuiltValueNullFieldError.checkNotNull(
        accountId, r'Transaction', 'accountId');
    BuiltValueNullFieldError.checkNotNull(
        description, r'Transaction', 'description');
    BuiltValueNullFieldError.checkNotNull(amount, r'Transaction', 'amount');
    BuiltValueNullFieldError.checkNotNull(date, r'Transaction', 'date');
  }

  @override
  Transaction rebuild(void Function(TransactionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TransactionBuilder toBuilder() => new TransactionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Transaction &&
        id == other.id &&
        accountId == other.accountId &&
        description == other.description &&
        amount == other.amount &&
        date == other.date;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, accountId.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Transaction')
          ..add('id', id)
          ..add('accountId', accountId)
          ..add('description', description)
          ..add('amount', amount)
          ..add('date', date))
        .toString();
  }
}

class TransactionBuilder implements Builder<Transaction, TransactionBuilder> {
  _$Transaction? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _accountId;
  String? get accountId => _$this._accountId;
  set accountId(String? accountId) => _$this._accountId = accountId;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  int? _amount;
  int? get amount => _$this._amount;
  set amount(int? amount) => _$this._amount = amount;

  DateTime? _date;
  DateTime? get date => _$this._date;
  set date(DateTime? date) => _$this._date = date;

  TransactionBuilder();

  TransactionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _accountId = $v.accountId;
      _description = $v.description;
      _amount = $v.amount;
      _date = $v.date;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Transaction other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Transaction;
  }

  @override
  void update(void Function(TransactionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Transaction build() => _build();

  _$Transaction _build() {
    final _$result = _$v ??
        new _$Transaction._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Transaction', 'id'),
            accountId: BuiltValueNullFieldError.checkNotNull(
                accountId, r'Transaction', 'accountId'),
            description: BuiltValueNullFieldError.checkNotNull(
                description, r'Transaction', 'description'),
            amount: BuiltValueNullFieldError.checkNotNull(
                amount, r'Transaction', 'amount'),
            date: BuiltValueNullFieldError.checkNotNull(
                date, r'Transaction', 'date'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
