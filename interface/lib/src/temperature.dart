import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

const String _c = "\u{2103}", _f = "\u{2109}";

/// An object that describe thermal of the animal.
///
/// This object defined 2 subtype of [Temperature]: [Celsius] and [Fahrenheit].
@immutable
@sealed
abstract class Temperature implements Comparable<Temperature> {
  /// A [double] that describe measure in this [unit].
  final double value;

  Temperature._(this.value) : assert(value.isFinite);

  /// A symbol that repersenting this [Temperature].
  String get unit;

  /// Get a [Temperature] from raw data of [value] and [unit] [symbol].
  ///
  /// If [symbol] is provided, value can be either [num] or numeric
  /// [String]. Otherwise, [value] must be a [String] and last charther must be
  /// validated [unit].
  ///
  /// If provided parameter does not stastified the requirement, it throw
  /// [TypeError].
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

    throw TypeError();
  }

  Temperature _toSameUnit(Temperature other);

  double _getOtherValue(Object other) {
    if (other is num) {
      return other.toDouble();
    } else if (other is Temperature) {
      return _toSameUnit(other).value;
    }

    throw TypeError();
  }

  /// Compare this [Temperature] to [other] in the same measurment.
  ///
  /// If this measurment is higher than [other], it return positive [int] and
  /// vice versa. It return `0` when this and [other] are the same measurment
  /// [value].
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

  /// Calculate hashed of [unit], [value] and [runtimeType].
  @override
  int get hashCode => hash3(runtimeType, value, unit);

  /// Check this [Temperature] has same [hashCode] with [other].
  ///
  /// For checking this [Temperauter] is repersenting same [Temperature] in
  /// measurment, use [equalsInMeasure] insteaded.
  @override
  bool operator ==(Object? other) => this.hashCode == other.hashCode;

  /// Check this [Temperature] has greater measurment of [other].
  bool operator >(Temperature other) => compareTo(other) > 0;

  /// Check this [Temperature] has lower measurment of [other].
  bool operator <(Temperature other) => compareTo(other) < 0;

  /// Check this [Temperature] has greater or equal measurment of [other].
  bool operator >=(Temperature other) => compareTo(other) >= 0;

  /// Check this [Temperature] has lower or equal measurment of [other].
  bool operator <=(Temperature other) => compareTo(other) <= 0;

  /// Check this [Temperature] has the same measurment of [other].
  ///
  /// For checking is equal with same [Object], use [==] insteaded.
  bool equalsInMeasure(Temperature other) => compareTo(other) == 0;

  /// Add [num] or [Temperature] in the same measurment.
  ///
  /// If [add] is [num], it assume [add] is using same unit on this
  /// [Temperature].
  Temperature operator +(Object add);

  /// Subtract [num] or [Temperature] in the same measurment.
  Temperature operator -(Object subtract);
}

/// A common [Temperature] unit uses most contries and regions.
class Celsius extends Temperature {
  /// Construct [Celsius] with [value] of measurment.
  Celsius(double value) : super._(value);

  /// Convert [fahrenheit]'s [value] to same measure in [Celsius].
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

/// Another unit for describing [Temperature] in some countries and regions.
class Fahrenheit extends Temperature {
  /// Construct [Fahrenheit] with [value] of measurment.
  Fahrenheit(double value) : super._(value);

  /// Convert [celsius]'s [value] to same measure in [Fahrenheit].
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
