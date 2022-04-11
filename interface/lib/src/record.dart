import 'package:meta/meta.dart';

import 'animal.dart' show Classification, AnimalMetadata;
import 'profile.dart';
import 'temperature.dart';

/// A data contains [Temperature] and recorded [DateTime].
///
/// This node usually store as [List].
@immutable
abstract class BodyTemperatureRecordNode {
  /// Recorded [temperature] at the moment.
  Temperature get temperature;

  /// When this node has been created, this [DateTime] suppose is UTC.
  DateTime get recordedAt;
}

/// Give additional methods for a [List] of [BodyTemperatureRecordNode] and
/// it's subclasses.
extension BodyTemperatureRecordNodeList<N extends BodyTemperatureRecordNode>
    on List<N> {
  /// [sort] [N] by [BodyTemperatureRecordNode.recordedAt].
  void sortByRecordedDate({bool reverse = false}) => this.sort((a, b) =>
      (reverse ? b : a).recordedAt.compareTo((reverse ? a : b).recordedAt));

  /// [sort] [N] by [BodyTemperatureRecordNode.temperature].
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

    assert((fromUtc == null || invokedAt.isAfter(fromUtc)) &&
        (toUtc == null ||
            invokedAt.isAfter(toUtc) ||
            invokedAt.isAtSameMomentAs(toUtc)));

    if (fromUtc == null && toUtc == null) {
      throw RangeError("Providing both null range is forbidden");
    } else if (fromUtc != null && toUtc != null) {
      assert(fromUtc.isBefore(toUtc));
    }

    return this.where((nodes) =>
        !(fromUtc?.isBefore(nodes.recordedAt) ?? false) &&
        !(toUtc?.isAfter(nodes.recordedAt) ?? false));
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
      this.where((nodes) =>
          profile.animal.classify(nodes.temperature) == classification);
}
