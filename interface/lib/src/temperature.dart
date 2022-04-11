import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

const String _c = "\u{2103}", _f = "\u{2109}";

@immutable
abstract class Temperature implements Comparable<Temperature> {
  double get value;
  String get unit;

  factory Temperature.parse({required Object value, String? symbol}) {
    double val;
    String s;

    if (symbol == null) {
      if (!(value is String)) {
        throw TypeError();
      }

      final int lastChar = value.length - 1;

      s = value[lastChar];
      val = double.parse(value.substring(0, lastChar));
    } else {
      if (value is num) {
        val = value.toDouble();
      } else if (value is String) {
        val = double.parse(value);
      } else {
        throw TypeError();
      }

      s = symbol;
    }

    switch (s) {
      case _c:
        return Celsius(val);
      case _f:
        return Fahrenheit(val);
    }

    throw AssertionError(
        "$s suppose be thrown already but reached at the end of the factory");
  }

  @override
  int compareTo(Temperature other);

  @override
  int get hashCode;

  @override
  bool operator ==(Object? other);

  bool operator >(Temperature other);

  bool operator <(Temperature other);

  bool operator >=(Temperature other);

  bool operator <=(Temperature other);

  bool equalsInMeasure(Temperature other);

  Temperature operator +(Object add);

  Temperature operator -(Object subtract);
}

@immutable
abstract class _Temperature implements Temperature {
  @override
  final double value;

  _Temperature(this.value) : assert(value.isFinite);

  Temperature _toSameUnit(Temperature other);

  double _getOtherValue(Object other) {
    if (other is num) {
      return other.toDouble();
    } else if (other is Temperature) {
      return _toSameUnit(other).value;
    }

    throw TypeError();
  }

  @override
  int compareTo(Temperature other) {
    Temperature sameUnit = _toSameUnit(other);

    double diff = value - sameUnit.value;

    if (diff > 0) {
      return 1;
    } else if (diff < 0) {
      return -1;
    }

    return 0;
  }

  @override
  int get hashCode => hash3(runtimeType, value, unit);

  @override
  bool operator ==(Object? other) => this.hashCode == other.hashCode;

  @override
  bool operator >(Temperature other) => compareTo(other) > 0;

  @override
  bool operator <(Temperature other) => compareTo(other) < 0;

  @override
  bool operator >=(Temperature other) => compareTo(other) >= 0;

  @override
  bool operator <=(Temperature other) => compareTo(other) <= 0;

  @override
  bool equalsInMeasure(Temperature other) => compareTo(other) == 0;
}

@immutable
@sealed
class Celsius extends _Temperature {
  Celsius(double value) : super(value);

  factory Celsius.fromFahrenheit(Fahrenheit fahrenheit) =>
      Celsius((fahrenheit.value - 32) * 5 / 9);

  @override
  Celsius operator +(Object add) => Celsius(this.value + _getOtherValue(add));

  @override
  Celsius operator -(Object subtract) =>
      Celsius(this.value - _getOtherValue(subtract));

  @override
  Celsius _toSameUnit(Temperature other) {
    if (other is Celsius) {
      return other;
    } else if (other is Fahrenheit) {
      return Celsius.fromFahrenheit(other);
    }

    throw TypeError();
  }

  @override
  String get unit => _c;
}

@immutable
@sealed
class Fahrenheit extends _Temperature {
  Fahrenheit(double value) : super(value);

  factory Fahrenheit.fromCelsius(Celsius celsius) =>
      Fahrenheit((celsius.value * 9 / 5) + 32);

  @override
  Fahrenheit operator +(Object add) =>
      Fahrenheit(this.value + _getOtherValue(add));

  @override
  Fahrenheit operator -(Object subtract) =>
      Fahrenheit(this.value - _getOtherValue(subtract));

  @override
  Fahrenheit _toSameUnit(Temperature other) {
    if (other is Fahrenheit) {
      return other;
    } else if (other is Celsius) {
      return Fahrenheit.fromCelsius(other);
    }

    throw TypeError();
  }

  @override
  String get unit => _f;
}
