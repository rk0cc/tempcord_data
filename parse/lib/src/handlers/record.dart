import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:meta/meta.dart';
import 'package:tempcord_data_interface/interface.dart'
    show BodyTemperatureRecordNode;

import '../typedef.dart' show CsvAttribute, CsvRow, Csv;
import 'converter.dart';

@sealed
class CsvRowItemMismatchedError extends StateError {
  final CsvAttribute attributes;
  final CsvRow row;

  CsvRowItemMismatchedError._(this.attributes, this.row)
      : assert(attributes.length != row.length),
        super("This CSV row items count is not equal with attribute provided");

  @override
  String toString() {
    return super.toString() +
        "\n\nAttribute: $attributes" +
        "\nRow: $row" +
        "\n\n";
  }
}

mixin BodyTemperatureRecordNodeCsvRowMixin on BodyTemperatureRecordNode {
  CsvRow toCsvRow();
}

mixin BodyTemperatureRecordListCsvMixin<
    N extends BodyTemperatureRecordNodeCsvRowMixin> on ListMixin<N> {
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

  Csv toCsv();
}

abstract class BodyTemperatureRecordListCsv<
        N extends BodyTemperatureRecordNodeCsvRowMixin> extends ListBase<N>
    with BodyTemperatureRecordListCsvMixin<N> {
  factory BodyTemperatureRecordListCsv(CsvAttribute attrubutes,
      [Iterable<N>? source]) = _BodyTemperatureRecordListCsv<N>;

  factory BodyTemperatureRecordListCsv.unmodifiable(
          CsvAttribute attribute, Iterable<N> source) =
      UnmodifiableBodyTemperatureRecordListCsv<N>;
}

class _BodyTemperatureRecordListCsv<
        N extends BodyTemperatureRecordNodeCsvRowMixin> extends ListBase<N>
    with BodyTemperatureRecordListCsvMixin<N>
    implements BodyTemperatureRecordListCsv<N> {
  @override
  final CsvAttribute attributes;
  final List<N> _nodes;

  _BodyTemperatureRecordListCsv(this.attributes, [Iterable<N>? source])
      : _nodes = source == null ? <N>[] : List.from(source);

  @override
  set length(int length) => _nodes.length = length;

  @override
  int get length => _nodes.length;

  @override
  N operator [](int index) => _nodes[index];

  @override
  void operator []=(int index, N value) => _nodes[index] = value;

  @override
  Csv toCsv() => _toCsv(false);
}

class UnmodifiableBodyTemperatureRecordListCsv<
        N extends BodyTemperatureRecordNodeCsvRowMixin>
    extends UnmodifiableListView<N>
    with BodyTemperatureRecordListCsvMixin<N>
    implements BodyTemperatureRecordListCsv<N> {
  @override
  final CsvAttribute attributes;

  UnmodifiableBodyTemperatureRecordListCsv(this.attributes, Iterable<N> source)
      : super(source);

  @override
  Csv toCsv() => _toCsv(true);
}

abstract class BodyTemperatureRecordListCsvConverter<
        N extends BodyTemperatureRecordNodeCsvRowMixin>
    implements TempcordDataConverter<BodyTemperatureRecordListCsv<N>> {
  static const ListToCsvConverter csvEncoder = ListToCsvConverter(eol: "\n");
  static const CsvToListConverter csvDecoder =
      CsvToListConverter(eol: "\n", shouldParseNumbers: false);

  @override
  BodyTemperatureRecordListCsv<N> decodeData(String dataStr);

  @override
  String encodeData(BodyTemperatureRecordListCsv<N> data) =>
      csvEncoder.convert(data.toCsv());
}