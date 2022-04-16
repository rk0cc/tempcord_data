import 'dart:collection';

import 'package:csv/csv.dart';
import 'package:meta/meta.dart';
import 'package:tempcord_data_interface/interface.dart'
    show BodyTemperatureRecordNode;

import '../typedef.dart' show CsvAttribute, CsvRow, Csv;
import '../converter.dart';

/// Subclass of [StateError] which thrown when at least one
/// [BodyTemperatureRecordNodeCsvRow.toCsvRow] has inequal items with
/// [BodyTemperatureRecordListCsvMixin.attributes].
@sealed
class CsvRowItemMismatchedError extends StateError {
  /// Current attribute applied from [BodyTemperatureRecordListCsvMixin].
  final CsvAttribute attributes;

  /// A [BodyTemperatureRecordNodeCsvRow] contains inequal item of [attributes].
  final CsvRow row;

  CsvRowItemMismatchedError._(this.attributes, this.row)
      : assert(attributes.length != row.length),
        super("This CSV row items count is not equal with attribute provided");

  @override
  String toString() {
    return "CsvRowItemMismatchedError: " +
        super.message +
        "\n\nAttribute: $attributes" +
        "\nRow: $row" +
        "\n\n";
  }
}

/// An implemented [BodyTemperatureRecordNode] that can be converted to CSV.
abstract class BodyTemperatureRecordNodeCsvRow
    implements BodyTemperatureRecordNode {
  /// Converted [List] of CSV date which corresponsed with
  /// [BodyTemperatureRecordListCsvMixin.attributes].
  CsvRow toCsvRow();
}

/// A [ListMixin] that handle [BodyTemperatureRecordNodeCsvRow] [List] based
/// and added converted to CSV feature.
mixin BodyTemperatureRecordListCsvMixin<
    N extends BodyTemperatureRecordNodeCsvRow> on ListMixin<N> {
  /// Attribute that repersent each column of
  /// [BodyTemperatureRecordNodeCsvRow.toCsvRow].
  CsvAttribute get attributes;

  Csv _toCsv(bool unmodified) {
    Csv csv = [attributes];

    for (N node in this) {
      CsvRow row = node.toCsvRow();

      if (row.length != attributes.length) {
        throw CsvRowItemMismatchedError._(attributes, row);
      }

      if (unmodified) {
        row = List.unmodifiable(row);
      }

      csv.add(row);
    }

    return unmodified ? List.unmodifiable(csv) : List.from(csv);
  }

  /// Export items in this [List] to CSV in Dart object.
  Csv toCsv();
}

/// An implemented [List] for collecting [BodyTemperatureRecordNodeCsvRow].
abstract class BodyTemperatureRecordListCsv<
        N extends BodyTemperatureRecordNodeCsvRow> extends ListBase<N>
    with BodyTemperatureRecordListCsvMixin<N> {
  /// Construct a growable [List] with provided [attribute].
  ///
  /// It can be parsed from [source] with existed item.
  factory BodyTemperatureRecordListCsv(CsvRow attrubutes,
      [Iterable<N>? source]) = BodyTemperatureRecordListCsvBase<N>;

  /// Construct a ungrowable [List] with provided [attribute] and [source]
  /// that repersenting data of [attribute].
  factory BodyTemperatureRecordListCsv.unmodifiable(
          CsvRow attribute, Iterable<N> source) =
      UnmodifiableBodyTemperatureRecordListCsv<N>;

  /// Copy [BodyTemperatureRecordListCsv] from origin [csv] with [unmodifiable]
  /// or not.
  factory BodyTemperatureRecordListCsv.copy(BodyTemperatureRecordListCsv<N> csv,
      {bool unmodifiable = false}) {
    CsvAttribute copiedAttr = UnmodifiableListView(csv.attributes);

    return unmodifiable
        ? UnmodifiableBodyTemperatureRecordListCsv(copiedAttr, csv)
        : BodyTemperatureRecordListCsvBase(copiedAttr, csv);
  }
}

/// An implemented [BodyTemperatureRecordListCsv] that function like a [List].
class BodyTemperatureRecordListCsvBase<
        N extends BodyTemperatureRecordNodeCsvRow> extends ListBase<N>
    with BodyTemperatureRecordListCsvMixin<N>
    implements BodyTemperatureRecordListCsv<N> {
  @override
  final CsvAttribute attributes;
  final List<N> _nodes;

  BodyTemperatureRecordListCsvBase(CsvRow attributes, [Iterable<N>? source])
      : this.attributes = UnmodifiableListView(attributes),
        _nodes = source == null ? <N>[] : List.from(source);

  @override
  set length(int length) => _nodes.length = length;

  @override
  int get length => _nodes.length;

  @override
  Iterator<N> get iterator => _nodes.iterator;

  @override
  void add(N element) => _nodes
      .add(element); // See this: https://github.com/dart-lang/sdk/issues/46646

  @override
  bool remove(Object? element) => _nodes.remove(element);

  @override
  N operator [](int index) => _nodes[index];

  @override
  void operator []=(int index, N value) => _nodes[index] = value;

  @override
  Csv toCsv() => _toCsv(false);
}

class UnmodifiableBodyTemperatureRecordListCsv<
        N extends BodyTemperatureRecordNodeCsvRow>
    extends UnmodifiableListView<N>
    with BodyTemperatureRecordListCsvMixin<N>
    implements BodyTemperatureRecordListCsv<N> {
  @override
  final CsvAttribute attributes;

  UnmodifiableBodyTemperatureRecordListCsv(
      CsvRow attributes, Iterable<N> source)
      : this.attributes = UnmodifiableListView<String>(attributes),
        super(List.from(source));

  @override
  Csv toCsv() => _toCsv(true);
}

abstract class BodyTemperatureRecordListCsvConverter<
        N extends BodyTemperatureRecordNodeCsvRow>
    implements TempcordDataConverter<BodyTemperatureRecordListCsv<N>> {
  static const ListToCsvConverter csvEncoder = ListToCsvConverter(eol: "\n");
  static const CsvToListConverter csvDecoder =
      CsvToListConverter(eol: "\n", shouldParseNumbers: false);

  const BodyTemperatureRecordListCsvConverter();

  @override
  BodyTemperatureRecordListCsv<N> decodeData(String dataStr);

  @override
  String encodeData(BodyTemperatureRecordListCsv<N> data) =>
      csvEncoder.convert(data.toCsv());
}
