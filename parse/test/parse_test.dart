import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:tempcord_data_parser/handlers.dart';
import 'package:tempcord_data_parser/parser.dart';
import 'package:tempcord_data_parser/src/typedef.dart';
import 'package:test/test.dart';

import 'mock/mock_btr.dart' hide OversizedMockBTRN;
import 'mock/mock_profile.dart';

class MockProfileParser extends ProfileJsonDataConverter<MockProfile> {
  const MockProfileParser();

  @override
  MockProfile decodeData(String dataStr) =>
      MockProfile.fromJson(jsonDecode(dataStr));
}

class MockBTRNParser extends BodyTemperatureRecordListCsvConverter<MockBTRN> {
  const MockBTRNParser();

  @override
  BodyTemperatureRecordListCsv<MockBTRN> decodeData(String dataStr) {
    Csv csvStr =
        BodyTemperatureRecordListCsvConverter.csvDecoder.convert(dataStr);

    CsvAttribute attribute = UnmodifiableListView<String>(csvStr.removeAt(0));

    return BodyTemperatureRecordListCsv.unmodifiable(
        attribute, csvStr.map((row) => MockBTRN.fromCsvRow(row)));
  }
}

void main() {
  TempcordDataParser<MockProfile, MockBTRN> mockParser = TempcordDataParser(
      profileConverter: const MockProfileParser(),
      btrlConverter: const MockBTRNParser());

  MockProfile mp =
      MockProfile("Sample", Animal.human, DateTime.utc(2012, 1, 1));

  BodyTemperatureRecordListCsv<MockBTRN> mbtrns = BodyTemperatureRecordListCsv(
      BodyTemperatureRecordListCsv.predefinedAttribute, <MockBTRN>[
    MockBTRN(Celsius(35), DateTime.utc(2020, 3, 5, 19, 30, 0)),
    MockBTRN(Celsius(35.7), DateTime.utc(2021, 3, 6, 19, 30, 0)),
    MockBTRN(Celsius(36.7), DateTime.utc(2021, 3, 6, 19, 45, 0))
  ]);

  group("Mock read and write test", () {
    late File exported;
    setUpAll(() {
      exported = File("./test/assets/exported.tcdtest");

      if (!exported.existsSync()) {
        exported.createSync(recursive: true);
      }
    });
    test("write test", () {
      Uint8List dataBytes = mockParser.writeBytes(profile: mp, btr: mbtrns);
      expect(() => exported.writeAsBytesSync(dataBytes, flush: true),
          returnsNormally);
    });
    test("read test", () {
      Uint8List readedDataByte = exported.readAsBytesSync();
      List<Object> decoded = mockParser.readBytes(readedDataByte);
      MockProfile parsedMockProfile = decoded[0] as MockProfile;
      BodyTemperatureRecordListCsv<MockBTRN> parsedMockBTRN =
          decoded[1] as BodyTemperatureRecordListCsv<MockBTRN>;

      expect(parsedMockProfile.name, equals("Sample"));
      expect(parsedMockProfile.animal, equals(Animal.human));
      expect(
          parsedMockBTRN
              .map((element) => element.temperature)
              .whereType<Celsius>()
              .length,
          equals(3));
      expect(parsedMockBTRN[0].temperature.value, equals(35));
    });
    tearDownAll(() {
      if (exported.existsSync()) {
        exported.deleteSync(recursive: true);
      }
    });
  }, testOn: "dart-vm");
}
