// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<MyTransaction> _$myTransactionSerializer =
    new _$MyTransactionSerializer();

class _$MyTransactionSerializer implements StructuredSerializer<MyTransaction> {
  @override
  final Iterable<Type> types = const [MyTransaction, _$MyTransaction];
  @override
  final String wireName = 'MyTransaction';

  @override
  Iterable<Object?> serialize(Serializers serializers, MyTransaction object,
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
  MyTransaction deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new MyTransactionBuilder();

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

class _$MyTransaction extends MyTransaction {
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

  factory _$MyTransaction([void Function(MyTransactionBuilder)? updates]) =>
      (new MyTransactionBuilder()..update(updates))._build();

  _$MyTransaction._(
      {required this.id,
      required this.accountId,
      required this.description,
      required this.amount,
      required this.date})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'MyTransaction', 'id');
    BuiltValueNullFieldError.checkNotNull(
        accountId, r'MyTransaction', 'accountId');
    BuiltValueNullFieldError.checkNotNull(
        description, r'MyTransaction', 'description');
    BuiltValueNullFieldError.checkNotNull(amount, r'MyTransaction', 'amount');
    BuiltValueNullFieldError.checkNotNull(date, r'MyTransaction', 'date');
  }

  @override
  MyTransaction rebuild(void Function(MyTransactionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MyTransactionBuilder toBuilder() => new MyTransactionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MyTransaction &&
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
    return (newBuiltValueToStringHelper(r'MyTransaction')
          ..add('id', id)
          ..add('accountId', accountId)
          ..add('description', description)
          ..add('amount', amount)
          ..add('date', date))
        .toString();
  }
}

class MyTransactionBuilder
    implements Builder<MyTransaction, MyTransactionBuilder> {
  _$MyTransaction? _$v;

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

  MyTransactionBuilder();

  MyTransactionBuilder get _$this {
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
  void replace(MyTransaction other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$MyTransaction;
  }

  @override
  void update(void Function(MyTransactionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MyTransaction build() => _build();

  _$MyTransaction _build() {
    final _$result = _$v ??
        new _$MyTransaction._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'MyTransaction', 'id'),
            accountId: BuiltValueNullFieldError.checkNotNull(
                accountId, r'MyTransaction', 'accountId'),
            description: BuiltValueNullFieldError.checkNotNull(
                description, r'MyTransaction', 'description'),
            amount: BuiltValueNullFieldError.checkNotNull(
                amount, r'MyTransaction', 'amount'),
            date: BuiltValueNullFieldError.checkNotNull(
                date, r'MyTransaction', 'date'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
