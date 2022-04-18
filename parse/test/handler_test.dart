import 'dart:convert';

import 'package:tempcord_data_parser/handlers.dart';
import 'package:tempcord_data_parser/src/handlers/record.dart'
    show BodyTemperatureRecordListCsvConverter;
import 'package:tempcord_data_parser/src/typedef.dart';
import 'package:test/test.dart';

import 'mock/mock_profile.dart';
import 'mock/mock_btr.dart';

void main() {
  group("Interface handler test", () {
    group("profile", () {
      test("to JSON", () {
        MockProfile mp =
            MockProfile("Foo", Animal.human, DateTime.utc(2000, 1, 1));
        expect(
            jsonEncode(mp.toJson()),
            equals(
                '{"name":"Foo","animal":0,"dob":"2000-01-01T00:00:00.000Z"}'));
        mp.updateName("Bar");
        expect(
            jsonEncode(mp.toJson()),
            equals(
                '{"name":"Foo","animal":0,"dob":"2000-01-01T00:00:00.000Z"}'));
        expect(
            jsonEncode(mp.updateName("Bar").toJson()),
            equals(
                '{"name":"Bar","animal":0,"dob":"2000-01-01T00:00:00.000Z"}'));
      });
      test("parse", () {
        String mockPJ =
            '{"name": "Sample", "animal": 0, "dob": "2000-01-01T00:00:00.000Z"}';
        MockProfile mp = MockProfile.fromJson(jsonDecode(mockPJ));

        expect(mp.name, equals("Sample"));
        expect(mp.animal, equals(Animal.human));
        expect(mp.dob.isAtSameMomentAs(DateTime.utc(2000, 1, 1)), isTrue);
      });
    });
    group("btr", () {
      BodyTemperatureRecordListCsv btrlc = BodyTemperatureRecordListCsvBase<
          MockBTRN>(["temp", "unit", "recordedAt"])
        ..addAll(<MockBTRN>[
          MockBTRN(Celsius(36), DateTime.utc(2021, 6, 3)),
          MockBTRN(Fahrenheit(99), DateTime.utc(2021, 9, 9)),
          MockBTRN(Celsius(37), DateTime.utc(2021, 9, 19))
        ]);
      test("convert to CSV string", () {
        const String exportedString =
            'temp,unit,recordedAt\n36.0,\u{2103},2021-06-03T00:00:00.000Z\n99.0,\u{2109},2021-09-09T00:00:00.000Z\n37.0,\u{2103},2021-09-19T00:00:00.000Z';
        expect(
            BodyTemperatureRecordListCsvConverter.csvEncoder
                .convert(btrlc.toCsv()),
            equals(exportedString));
      });
      test("encode failed if applied mismatched attributes counts", () {
        BodyTemperatureRecordListCsv copied =
            BodyTemperatureRecordListCsv.copy(btrlc);
        expect(() {
          copied.add(
              OversizedMockBTRN(Celsius(37.2), DateTime.utc(2021, 10, 12), 1));
          return copied.toCsv();
        }, throwsA(isA<CsvRowItemMismatchedError>()));
      });
      test("convert back to object", () {
        // Skip CSV string to 2D list process
        CsvRow sampleRow = ["36.4", "\u{2103}", "2022-01-03T00:00:00.000Z"];

        MockBTRN parsed = MockBTRN.fromCsvRow(sampleRow);

        expect(parsed.temperature, equals(Celsius(36.4)));
        expect(parsed.recordedAt.isAtSameMomentAs(DateTime.utc(2022, 1, 3)),
            isTrue);
      });
    });
  });
}
