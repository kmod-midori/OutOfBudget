import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'account.dart';
import 'transaction.dart';

part 'serializers.g.dart';

@SerializersFor([Account, Transaction])
final Serializers serializers = _$serializers;
final standardSerializers = (serializers.toBuilder()
      ..addPlugin(
        StandardJsonPlugin(),
      ))
    .build();
