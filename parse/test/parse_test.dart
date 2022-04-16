@Skip("Sample data not ready yet")

import 'dart:collection';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:html' as html;

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

  group("Mock write test", () {
    group("on VM", () {
      late io.File exported;
      setUpAll(() {
        exported = io.File("./test/assets/exported.tcdtest");

        if (!exported.existsSync()) {
          exported.createSync(recursive: true);
        }
      });
      tearDownAll(() {
        if (exported.existsSync()) {
          exported.deleteSync(recursive: true);
        }
      });
    }, testOn: "dart-vm");
    test("on browser", () {}, testOn: "browser");
  });
}
