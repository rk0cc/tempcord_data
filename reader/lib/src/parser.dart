import 'dart:convert';

import 'package:tempcord_data_parser/handlers.dart';
import 'package:tempcord_data_parser/parser.dart';

class _DefaultProfile extends ProfileJson {
  @override
  final Animal animal;

  @override
  final String name;

  _DefaultProfile(this.name, this.animal);

  factory _DefaultProfile.fromJson(Json json) =>
      _DefaultProfile(json["name"], Animal.values[json["animal"]]);

  @override
  Json toJson() => {"name": name, "animal": animal.index};

  @override
  Profile updateAnimal(Animal animal) {
    throw UnsupportedError("This profile is read-only");
  }

  @override
  Profile updateName(String name) {
    throw UnsupportedError("This profile is read-only");
  }
}

class _DefaultProfileConverter
    extends ProfileJsonDataConverter<_DefaultProfile> {
  const _DefaultProfileConverter();

  @override
  _DefaultProfile decodeData(String dataStr) =>
      _DefaultProfile.fromJson(jsonDecode(dataStr));
}

class _DefaultBTRN extends BodyTemperatureRecordNodeCsvRow {
  @override
  final DateTime recordedAt;

  @override
  final Temperature temperature;

  _DefaultBTRN(this.temperature, this.recordedAt) : assert(recordedAt.isUtc);

  factory _DefaultBTRN.fromCsvRow(CsvRow row) => _DefaultBTRN(
      Temperature.parse(value: row[0], symbol: row[1]), DateTime.parse(row[2]));

  @override
  CsvRow toCsvRow() => [
        temperature.value.toString(),
        temperature.unit,
        recordedAt.toIso8601String()
      ];
}

class _DefaultBTRNConverter
    extends BodyTemperatureRecordListCsvConverter<_DefaultBTRN> {
  const _DefaultBTRNConverter();

  @override
  BodyTemperatureRecordListCsv<_DefaultBTRN> decodeData(String dataStr) =>
      UnmodifiableBodyTemperatureRecordListCsv(
          BodyTemperatureRecordListCsv.predefinedAttribute,
          BodyTemperatureRecordListCsvConverter.csvDecoder
              .convert<String>(dataStr)
              .map(_DefaultBTRN.fromCsvRow));
}

/// Parser that using standard implementation
final TempcordDataParser genericParser = TempcordDataParser(
    profileConverter: const _DefaultProfileConverter(),
    btrlConverter: const _DefaultBTRNConverter());
