//@Skip("Sample data not ready yet")

import 'dart:collection';
import 'dart:convert';

import 'package:tempcord_data_parser/handlers.dart';
import 'package:tempcord_data_parser/parser.dart';
import 'package:tempcord_data_parser/src/typedef.dart';
import 'package:test/test.dart';

import 'mock/mock_btr.dart' hide OversizedMockBTRN;
import 'mock/mock_profile.dart';
import 'parse_platform/genreic.dart'
    if (dart.library.io) "parse_platform/vm.dart"
    if (dart.library.html) "parse_platform/web.dart";

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
    testOnPlatform(mockParser, mp, mbtrns);
  });
}
