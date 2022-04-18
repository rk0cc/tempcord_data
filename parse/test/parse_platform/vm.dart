import 'dart:io';
import 'dart:typed_data';

import 'package:tempcord_data_parser/handlers.dart';
import 'package:tempcord_data_parser/parser.dart';
import 'package:test/test.dart';

import '../mock/mock_btr.dart';
import '../mock/mock_profile.dart';

void testOnPlatform(TempcordDataParser<MockProfile, MockBTRN> mockParser,
    MockProfile mp, BodyTemperatureRecordListCsv<MockBTRN> mbtrns) {
  group("on VM", () {
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
