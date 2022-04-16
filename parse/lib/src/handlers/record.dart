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

  /// {@template btrl2Csv}
  ///
  /// Export items in this [List] to CSV in Dart object.
  ///
  /// {@endtemplate}
  Csv toCsv();
}

/// An implemented [List] for collecting [BodyTemperatureRecordNodeCsvRow].
abstract class BodyTemperatureRecordListCsv<
        N extends BodyTemperatureRecordNodeCsvRow> extends ListBase<N>
    with BodyTemperatureRecordListCsvMixin<N> {
  /// An attribute that should be predefined if meet requirement of data
  /// standard.
  static CsvRow get predefinedAttribute => ["temp", "unit", "recordedAt"];

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

  /// Set a new [length] of this [List].
  @override
  set length(int length);

  /// Current items exist in this [List].
  @override
  int get length;

  /// Return [Iterator] that iterating this [List].
  @override
  Iterator<N> get iterator;

  /// Append [element] to this [List].
  @override
  void add(N element);

  /// Remove provided [element] in this [List].
  @override
  bool remove(Object? element);

  /// Get an item which in [index].
  @override
  N operator [](int index);

  /// Assign new [value] on provided [index].
  @override
  void operator []=(int index, N value);
}

/// An implemented [BodyTemperatureRecordListCsv] that function like a [List].
class BodyTemperatureRecordListCsvBase<
        N extends BodyTemperatureRecordNodeCsvRow> extends ListBase<N>
    with BodyTemperatureRecordListCsvMixin<N>
    implements BodyTemperatureRecordListCsv<N> {
  @override
  final CsvAttribute attributes;

  final List<N> _nodes;

  /// Construct [BodyTemperatureRecordListCsvBase] with given [attributes].
  ///
  /// By default, it return a empty [List]. If [source] provided, the origin
  /// [Iterable] will be applied.
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

  /// Construct a [List] from origin [source] and disallow modification on
  /// this [List].
  UnmodifiableBodyTemperatureRecordListCsv(
      CsvRow attributes, Iterable<N> source)
      : this.attributes = UnmodifiableListView<String>(attributes),
        super(List.from(source));

  /// {@macro btrl2Csv}
  ///
  /// However, every [String] contains in every [List] also can not be modified.
  @override
  Csv toCsv() => _toCsv(true);
}

/// A [TempcordDataConverter] for handle conversion between
/// [BodyTemperatureRecordListCsv] and a [String] of 2D [List].
///
/// It predefined [ListToCsvConverter] and [CsvToListConverter] which suppose to
/// be used for standarise file data and discourage to use custom constructed
/// converter.
///
/// The expected result should be liked this:
/// ```csv
/// temp,unit,recordedAt
/// 36.0,℃,2021-02-23T09:02:42.000Z
/// 35.9,℃,2021-04-13T13:34:59.000Z
/// 37.1,℃,2021-12-09T03:17:20.000Z
/// ```
abstract class BodyTemperatureRecordListCsvConverter<
        N extends BodyTemperatureRecordNodeCsvRow>
    implements TempcordDataConverter<BodyTemperatureRecordListCsv<N>> {
  /// Provided converter that convert [List] to CSV [String].
  static const ListToCsvConverter csvEncoder = ListToCsvConverter(eol: "\n");

  /// Provided converter that convert CSV [String] to [List].
  static const CsvToListConverter csvDecoder =
      CsvToListConverter(eol: "\n", shouldParseNumbers: false);

  /// Construct converter for converting [BodyTemperatureRecordListCsv].
  const BodyTemperatureRecordListCsvConverter();

  @override
  BodyTemperatureRecordListCsv<N> decodeData(String dataStr);

  @override
  String encodeData(BodyTemperatureRecordListCsv<N> data) =>
      csvEncoder.convert(data.toCsv());
}
