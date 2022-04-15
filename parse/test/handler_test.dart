@Skip("Mock object not implemented yet")

import 'dart:convert';

import 'package:tempcord_data_parser/handlers.dart';
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
            mp.updateName("Bar").toJson(),
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
      BodyTemperatureRecordListCsv btrlc =
          BodyTemperatureRecordListCsv(["temp", "unit", "recordedAt"]);
    });
  });
}
