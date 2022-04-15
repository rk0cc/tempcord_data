import 'dart:collection';

import 'package:tempcord_data_interface/interface.dart';
import 'package:tempcord_data_interface/type.dart';
import 'package:test/test.dart';

import 'profile_test.dart' show MockProfile;

class MockRecordNode implements BodyTemperatureRecordNode {
  @override
  final DateTime recordedAt;

  @override
  final Temperature temperature;

  MockRecordNode(this.temperature, this.recordedAt);
}

class MockProfileRecordList extends UnmodifiableListView<MockRecordNode>
    with ProfileBodyTemperatureRecordListMixin<MockProfile, MockRecordNode> {
  @override
  final MockProfile profile;

  MockProfileRecordList(this.profile, Iterable<MockRecordNode> source)
      : super(source);
}

void main() {
  group("Body temperature record list", () {
    group("extension", () {
      List<MockRecordNode> mrn = <MockRecordNode>[
        MockRecordNode(Celsius(37), DateTime(2021, 3, 1)),
        MockRecordNode(Celsius(36.9), DateTime(2022, 2, 3)),
        MockRecordNode(Fahrenheit(99.6), DateTime(2021, 9, 28)),
        MockRecordNode(Fahrenheit(97.4), DateTime(2020, 6, 2))
      ];

      test("sorting", () {
        mrn.sortByTemperature();
        expect(mrn[0].temperature, isA<Fahrenheit>());
        expect(mrn[1].temperature.value, equals(36.9));

        mrn.sortByRecordedDate();
        expect(
            mrn[0].recordedAt.isAtSameMomentAs(DateTime(2020, 6, 2)), isTrue);
        expect(
            mrn[1].recordedAt.isAtSameMomentAs(DateTime(2021, 3, 1)), isTrue);
      });

      test("where", () {
        expect(
            mrn.whereRecordedAt(from: DateTime(2020, 12, 1)).length, equals(3));
        expect(() => mrn.whereRecordedAt(), throwsRangeError);
      });
    });
    group("profile mixin", () {
      List<MockRecordNode> mrn = <MockRecordNode>[
        MockRecordNode(
            Celsius(37.8), DateTime(2021, 12, 31)), // Hyperthermia (strict)
        MockRecordNode(
            Celsius(38.0), DateTime(2021, 1, 2)), // Hyperthermia (strict)
        MockRecordNode(Celsius(36.9), DateTime(2020, 12, 9)), // Normal
        MockRecordNode(Celsius(39.4), DateTime(2020, 11, 9)), // Hyperthermia
        MockRecordNode(Fahrenheit(101.2), DateTime(2021, 2, 1)), // Hyperthermia
        MockRecordNode(Fahrenheit(99.0), DateTime(2021, 3, 1)), // Normal
        MockRecordNode(Fahrenheit(94), DateTime(2020, 7, 1)), // Hypothermia
        MockRecordNode(Celsius(34.5), DateTime(2021, 5, 3)) // Hypothermia
      ];
      MockProfileRecordList mprl =
          MockProfileRecordList(MockProfile("Foo", Animal.human), mrn);

      test(
          "low temp",
          () => expect(mprl.whereClassified(Classification.hypothermia).length,
              equals(2)));
      test("normal", () {
        expect(mprl.whereClassified(Classification.normal).length, equals(4));
        expect(mprl.whereClassified(Classification.normal, strict: true).length,
            equals(2));
      });

      test("high temp", () {
        expect(mprl.whereClassified(Classification.hyperthermia).length,
            equals(2));
        expect(
            mprl
                .whereClassified(Classification.hyperthermia, strict: true)
                .length,
            equals(4));
      });

      test("no extension method called for mixin implemented list", () {
        expect(
            () => mrn.whereClassifiedByProfile(
                MockProfile("Bar", Animal.human), Classification.normal),
            returnsNormally);
        expect(
            () => mprl.whereClassifiedByProfile(
                MockProfile("Baz", Animal.human), Classification.normal),
            throwsUnsupportedError);
      });
    });
  });
}
