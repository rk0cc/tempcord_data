import 'package:meta/meta.dart';

import 'animal.dart' show Classification, AnimalMetadata;
import 'profile.dart';
import 'temperature.dart';

@immutable
abstract class BodyTemperatureRecordNode {
  Temperature get temperature;
  DateTime get recordedAt;
}

extension BodyTemperatureRecordNodeList<N extends BodyTemperatureRecordNode>
    on List<N> {
  void sortByRecordedDate({bool reverse = false}) => this.sort((a, b) =>
      (reverse ? b : a).recordedAt.compareTo((reverse ? a : b).recordedAt));

  void sortByTemperature({bool reverse = false}) => this.sort(((a, b) =>
      (reverse ? b : a).temperature.compareTo((reverse ? a : b).temperature)));

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

mixin ProfileBodyTemperatureRecordListMixin<N extends BodyTemperatureRecordNode>
    on List<N> {
  Profile get profile;

  Iterable<N> whereClassified(Classification classification,
          {bool strict = false}) =>
      this.where((nodes) =>
          profile.animal.classify(nodes.temperature) == classification);
}
