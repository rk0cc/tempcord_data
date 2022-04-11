import 'package:tempcord_data_interface/type.dart';
import 'package:test/test.dart';

void main() {
  group("Temperature parse test", () {
    test("return type", () {
      expect(Temperature.parse(value: "36.3\u{2103}"), isA<Celsius>());
      expect(Temperature.parse(value: "97.5\u{2109}"), isA<Fahrenheit>());
      expect(
          Temperature.parse(value: 36.9, symbol: "\u{2103}"), isA<Celsius>());
      expect(Temperature.parse(value: 99.0, symbol: "\u{2109}"),
          isA<Fahrenheit>());
    });
    test("invalid parse", () {
      expect(() => Temperature.parse(value: 35), throwsA(isA<TypeError>()));
      expect(() => Temperature.parse(value: "98.7"), throwsA(isA<TypeError>()));
    });
  });
}
