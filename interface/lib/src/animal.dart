import 'package:meta/meta.dart';

import 'temperature.dart';

/// Classify does [Animal]'s body [Temperature] stay a suitable range.
enum Classification {
  /// Too cold for [Animal].
  hypothermia,

  /// Stastified for [Animal].
  normal,

  /// Too hot for [Animal], also know as "fever".
  hyperthermia
}

/// Metadata to define [Animal]'s body temperature [Classification].
@sealed
class _BodyTemperatureMetadata {
  /// Minimum of [Temperature] range for [Animal] that [classify] as
  /// [Classification.normal].
  final Temperature minNormal;

  /// Maximum of [Temperature] range for [Animal] that [classify] as
  /// [Classification.normal] in strict mode.
  final Temperature maxStrictNormal;

  /// Maximum of [Temperature] range for [Animal] that [classify] as
  /// [Classification.normal].
  final Temperature maxNormal;

  _BodyTemperatureMetadata(this.minNormal, this.maxNormal,
      [Temperature? maxStrictNormal])
      : assert(minNormal < maxNormal,
            "Minimum normal temperature should be lower than maximum"),
        assert(maxStrictNormal == null || maxStrictNormal < maxNormal,
            "Maximum strict normal temperature should be lower than maximum if provided"),
        this.maxStrictNormal = maxStrictNormal ?? maxNormal;

  /// Get a [Classification] by giving [temperature].
  ///
  /// When [strict] set `true`, it uses [maxStrictNormal] to replace [maxNormal]
  /// when checking is [Classification.hyperthermia].
  Classification classify(Temperature temperature, bool strict) {
    if (temperature < minNormal) {
      return Classification.hypothermia;
    } else if (temperature > (strict ? maxStrictNormal : maxNormal)) {
      return Classification.hyperthermia;
    }

    return Classification.normal;
  }
}

/// An [Enum] that contain supported type of [Animal] which is warm-blooded.
enum Animal { human }

/// Get a metadata of [Animal].
extension AnimalMetadata on Animal {
  _BodyTemperatureMetadata get _metadata {
    switch (this) {
      case Animal.human:
        return _BodyTemperatureMetadata(
            Celsius(35), Celsius(38.2), Celsius(37.5));
    }
  }

  /// To classify [temperature] for this [Animal].
  ///
  /// The [temperature] of [Classification.hyperthermia] is lower if [strict]
  /// set to `true`.
  Classification classify(Temperature temperature, {bool strict = false}) =>
      _metadata.classify(temperature, strict);
}
