import 'dart:convert';

import 'package:tempcord_data_interface/interface.dart' show Profile;

import '../typedef.dart' show Json;
import 'converter.dart';

mixin ProfileJsonMixin on Profile {
  Json toJson();
}

abstract class ProfileJsonDataConverter<P extends ProfileJsonMixin>
    implements TempcordDataConverter<P> {
  @override
  P decodeData(String dataStr);

  @override
  String encodeData(P data) => jsonEncode(data.toJson());
}
