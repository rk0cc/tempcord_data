import 'dart:convert';
import 'dart:io';

import 'package:tempcord_data_parser/handlers.dart';
import 'package:tempcord_data_parser/parser.dart';

// Construct profile and body temperature record nodes
class ExampleProfile implements ProfileJson {
  @override
  final Animal animal;

  @override
  final String name;

  ExampleProfile({required this.name, required this.animal});

  factory ExampleProfile.parse(Json json) =>
      ExampleProfile(name: json["name"], animal: Animal.values[json["animal"]]);

  @override
  Json toJson() => {"name": name, "animal": animal.index};

  @override
  ExampleProfile updateAnimal(Animal animal) =>
      ExampleProfile(name: this.name, animal: animal);

  @override
  ExampleProfile updateName(String name) =>
      ExampleProfile(name: name, animal: this.animal);
}

class ExampleBTRN implements BodyTemperatureRecordNodeCsvRow {
  @override
  final DateTime recordedAt;

  @override
  final Temperature temperature;

  ExampleBTRN({required this.temperature, required this.recordedAt})
      : assert(recordedAt.isUtc);

  factory ExampleBTRN.parse(CsvRow csvRow) => ExampleBTRN(
      temperature: Temperature.parse(value: csvRow[0], symbol: csvRow[1]),
      recordedAt: DateTime.parse(csvRow[2]));

  @override
  CsvRow toCsvRow() => [
        temperature.value.toString(),
        temperature.unit,
        recordedAt.toIso8601String()
      ];
}

// Build parser
class ExampleProfileParser extends ProfileJsonDataConverter<ExampleProfile> {
  @override
  ExampleProfile decodeData(String dataStr) =>
      ExampleProfile.parse(jsonDecode(dataStr));

  /*
    You can override default encoded data, but dropped compatable feature
    when using official provided reader.
  */
  @override
  String encodeData(ExampleProfile data) => jsonEncode(data.toJson());
}

class ExampleBTRNParser
    extends BodyTemperatureRecordListCsvConverter<ExampleBTRN> {
  @override
  BodyTemperatureRecordListCsv<ExampleBTRN> decodeData(String dataStr) {
    Csv parsed =
        // You can use your own CSV parser, but no compatiblity feature.
        BodyTemperatureRecordListCsvConverter.csvDecoder.convert(dataStr);

    return BodyTemperatureRecordListCsv(
        BodyTemperatureRecordListCsv.predefinedAttribute,
        parsed.map((e) => ExampleBTRN.parse(e)));
  }
}

void main() async {
  /*
    This example is based on Dart VM.

    It can be read under HTML but more complicated than using VM as example.
  */

  File file = File("path/to/tempcord/file");

  final TempcordDataParser<ExampleProfile, ExampleBTRN> parser =
      TempcordDataParser(
          profileConverter: ExampleProfileParser(),
          btrlConverter: ExampleBTRNParser(),
          additionalConverter: [
        // Put which additional data can be parsed here
      ]);

  // Parse tempcord object from bytes
  List<Object> parsedTC = parser.readBytes(await file.readAsBytes());

  // Get profile from defined index
  ExampleProfile p = parsedTC[0] as ExampleProfile;

  // Get additional data
  // Object additionalData = parsedTC[2]; // Index must be >= 2

  // Edit profile
  p = p.updateName("Alex");

  // Update record file
  file = await file.writeAsBytes(parser.writeBytes(
      profile: p,
      btr: parsedTC[1] as BodyTemperatureRecordListCsv<ExampleBTRN>));
}
