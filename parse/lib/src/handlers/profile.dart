import 'dart:convert';

import 'package:tempcord_data_interface/interface.dart' show Profile;

import '../typedef.dart' show Json;
import '../converter.dart';

/// An implementation that allows [Profile] can be store under JSON format.
abstract class ProfileJson
    implements Profile, TempcordDataConvertedObject<Json> {
  /// Convert [Profile] data to JSON format.
  ///
  /// The JSON format must be follow this [schema](https://github.com/rk0cc/tempcord_data/blob/main/docs/schema/profile_schema.json):
  ///
  /// ```json
  /// {
  ///   "name": "(Profile name)",
  ///   "animal": 0
  /// }
  /// ```
  Json toJson();

  @override
  Json toData() => toJson();
}

/// A [TempcordDataConverter] for converting between [ProfileJson] and
/// stringfied JSON data.
abstract class ProfileJsonDataConverter<P extends ProfileJson>
    implements TempcordDataConverter<Json, P> {
  /// Construct converter for [ProfileJson].
  const ProfileJsonDataConverter();

  @override
  P decodeData(String dataStr);

  @override
  String encodeData(P data) => jsonEncode(data.toJson());
}
