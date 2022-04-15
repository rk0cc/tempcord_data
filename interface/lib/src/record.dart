import 'dart:collection';

import 'package:meta/meta.dart';

import 'animal.dart' show Classification, AnimalMetadata;
import 'profile.dart';
import 'temperature.dart';

/// A data contains [Temperature] and recorded [DateTime].
///
/// This node usually store as [List].
@immutable
abstract class BodyTemperatureRecordNode {
  external BodyTemperatureRecordNode(Temperature temperature,
      [DateTime? recordedAt]);

  /// Recorded [temperature] at the moment.
  Temperature get temperature;

  /// When this node has been created, this [DateTime] suppose is UTC.
  DateTime get recordedAt;
}

/// Give additional methods for a [List] of [BodyTemperatureRecordNode] and
/// it's subclasses.
extension BodyTemperatureRecordNodeListExtension<
    N extends BodyTemperatureRecordNode> on List<N> {
  /// [sort] [N] by [BodyTemperatureRecordNode.recordedAt].
  ///
  /// This can not be called if this [List] is [UnmodifiableListView] which
  /// it throw [UnsupportedError] when calling [UnmodifiableListView.sort].
  void sortByRecordedDate({bool reverse = false}) => this.sort((a, b) =>
      (reverse ? b : a).recordedAt.compareTo((reverse ? a : b).recordedAt));

  /// [sort] [N] by [BodyTemperatureRecordNode.temperature].
  ///
  /// This can not be called if this [List] is [UnmodifiableListView] which
  /// it throw [UnsupportedError] when calling [UnmodifiableListView.sort].
  void sortByTemperature({bool reverse = false}) => this.sort(((a, b) =>
      (reverse ? b : a).temperature.compareTo((reverse ? a : b).temperature)));

  /// Return [where] [N] recorded [from] and [to].
  ///
  /// [from] and [to] can be nulled if not applied. However, they can not be
  /// nulled at the same time which throw [RangeError].
  ///
  /// [from] and [to] should be before [DateTime.now] when this method invoked.
  Iterable<N> whereRecordedAt({DateTime? from, DateTime? to}) {
    final DateTime invokedAt = DateTime.now().toUtc();
    final DateTime? fromUtc = from?.toUtc(), toUtc = to?.toUtc();

    assert(
        (fromUtc == null || !invokedAt.isBefore(fromUtc)) &&
            (toUtc == null || !invokedAt.isBefore(toUtc)),
        "The time range included future time is forbidden");

    if (fromUtc == null && toUtc == null) {
      throw RangeError("Providing both null range is forbidden");
    } else if (fromUtc != null && toUtc != null) {
      assert(!fromUtc.isAfter(toUtc), "Reversed time range applied");
    }

    return this.where((nodes) =>
        !(fromUtc?.isAfter(nodes.recordedAt) ?? false) &&
        !(toUtc?.isBefore(nodes.recordedAt) ?? false));
  }
}

/// An extension that fetch A [List] that related to [BodyTemoeratureRecordNode]
/// by [Profile].
extension BodyTemperatureRecordListProfileExtension<
    N extends BodyTemperatureRecordNode> on List<N> {
  Iterable<N> _whereClassifiedByProfile(
          Profile profile, Classification classification,
          {bool strict = false}) =>
      this.where((nodes) =>
          profile.animal.classify(nodes.temperature, strict: strict) ==
          classification);

  /// Find [where] [N] classified to related [classification] depending
  /// animal type of [profile].
  ///
  /// If [strict] enabled, the condition of [Classification.hyperthermia] uses
  /// lower [Temperature] one.
  ///
  /// This method **can not** be called in
  /// [ProfileBodyTemperatureRecordListMixin] which it provides
  /// [ProfileBodyTemperatureRecordListMixin.whereClassified] for
  /// [ProfileBodyTemperatureRecordListMixin.profile].
  Iterable<N> whereClassifiedByProfile(
      Profile profile, Classification classification,
      {bool strict = false}) {
    if (this is ProfileBodyTemperatureRecordListMixin) {
      throw new UnsupportedError(
          "Profile given list mixin can not use this method");
    }

    return this
        ._whereClassifiedByProfile(profile, classification, strict: strict);
  }
}

/// A mixin that added feature that rely on [Profile] and it's subclasses.
mixin ProfileBodyTemperatureRecordListMixin<P extends Profile,
    N extends BodyTemperatureRecordNode> on List<N> {
  /// Profile applied to uses in this mixin.
  P get profile;

  /// Find [where] [N] classified to related [classification] depending
  /// animal type of [Profile].
  Iterable<N> whereClassified(Classification classification,
          {bool strict = false}) =>
      this._whereClassifiedByProfile(this.profile, classification,
          strict: strict);
}
