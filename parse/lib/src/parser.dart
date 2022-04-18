import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:lzma/lzma.dart';
import 'package:meta/meta.dart';

import 'converter.dart';
import 'handlers/profile.dart';
import 'handlers/record.dart';

/// Define various [TempcordDataConverter] for handling conversion on
/// [TempcordDataConvertedObject].
typedef GenericTempcordDataConverter
    = TempcordDataConverter<Object, TempcordDataConvertedObject>;

/// A [Set] that based on [Type] instead of [Object.hashCode] to prevent same
/// [Type] of [GenericTempcordDataConverter] applied.
class _ConverterSet extends SetBase<GenericTempcordDataConverter> {
  final Map<Type, GenericTempcordDataConverter> _converters = {};

  /// Append [GenericTempcordDataConverter] to this set.
  ///
  /// It return false if [value] is in the [Set] already.
  @override
  bool add(GenericTempcordDataConverter value) {
    if (_converters.containsKey(value.runtimeType)) {
      return false;
    }

    _converters[value.runtimeType] = value;

    return true;
  }

  /// Check the [GenericTempcordDataConverter] is in this [Set] already.
  @override
  bool contains(Object? element) => _converters.containsValue(element);

  /// Return a [Iterator] of [GenericTempcordDataConverter].
  @override
  Iterator<GenericTempcordDataConverter> get iterator =>
      _converters.values.iterator;

  /// Get count of [GenericTempcordDataConverter] applied in this [Set].
  @override
  int get length => _converters.length;

  /// Get the [element] is in this [Set].
  @override
  TempcordDataConverter<Object, TempcordDataConvertedObject<Object>>? lookup(
          Object? element) =>
      _converters[element];

  /// Remove [GenericTempcordDataConverter] in this [Set].
  @override
  bool remove(Object? value) {
    if (!_converters.containsValue(value)) {
      return false;
    }

    int origin = _converters.length;
    _converters.removeWhere((k, v) => v == value);

    return _converters.length < origin;
  }

  /// Return [Set] with same order but referenced by [Object.hashCode].
  @override
  Set<GenericTempcordDataConverter> toSet() => _converters.values.toSet();
}

/// Convert the data between [Uint8List] and corresponded
/// [TempcordDataConvertedObject] (including [P] and a [List] of [N]).
@sealed
class TempcordDataParser<P extends ProfileJson,
    N extends BodyTemperatureRecordNodeCsvRow> {
  static const String _dataDivider = "\u{241E}";

  final _ConverterSet _converters;

  TempcordDataParser._(this._converters);

  /// Construct [TempcordDataParser].
  ///
  /// The format of the exported data must be followed this order:
  /// 1. [ProfileJson].
  /// 2. [BodyTemperatureRecordListCsv] with [BodyTemperatureRecordNodeCsvRow].
  /// 3. (Your own implemented [additionalConverter]).
  ///
  /// These order should be return the same type order of [readBytes]. And no
  /// duplicated type defined in [additionalConverter].
  factory TempcordDataParser(
          {required ProfileJsonDataConverter<P> profileConverter,
          required BodyTemperatureRecordListCsvConverter<N> btrlConverter,
          List<GenericTempcordDataConverter>? additionalConverter}) =>
      TempcordDataParser._(_ConverterSet()
        ..add(profileConverter)
        ..add(btrlConverter)
        ..addAll(additionalConverter ?? <GenericTempcordDataConverter>[]));

  /// Convert all provided [datas] to a single [String] with [_dataDivider]
  /// to isolate data.
  String _dataToStr(List<TempcordDataConvertedObject> datas) {
    assert(datas.length == _converters.length,
        "Provided data length must be the same with the applied converter");

    List<String> dataStr = [];
    for (int i = 0; i < _converters.length; i++) {
      dataStr.add(_converters.elementAt(i).encodeData(datas[i]));
    }

    return dataStr.join(_dataDivider);
  }

  /// Convert to parsed [TempcordDataConvertedObject] from a single [String].
  List<TempcordDataConvertedObject> _strToData(String str) {
    List<String> spiltedData = str.split(_dataDivider);

    assert(spiltedData.length == _converters.length,
        "Data sections and converters counts must be equal in this parser");

    List<Object> dataObj = [];
    for (int i = 0; i < _converters.length; i++) {
      dataObj.add(_converters.elementAt(i).decodeData(spiltedData[i]));
    }

    return List.unmodifiable(dataObj);
  }

  /// Write [TempcordDataConvertedObject] to [Uint8List] with [lzma]
  /// compression.
  ///
  /// [addition] will be used if applied addition [TempcordDataConverter] on
  /// constructor and should be exact same order between the converter and
  /// corresponded object.
  Uint8List writeBytes(
          {required P profile,
          required BodyTemperatureRecordListCsv<N> btr,
          List<TempcordDataConvertedObject<Object>>? addition}) =>
      UnmodifiableUint8ListView(Uint8List.fromList(lzma.encode(utf8.encode(
          _dataToStr(<TempcordDataConvertedObject>[profile, btr]
            ..addAll(addition ?? <TempcordDataConvertedObject>[]))))));

  /// Convert [bytes] to a [List] of [TempcordDataConvertedObject].
  ///
  /// The index of the [List] should be exact same order of how
  /// [TempcordDataConverter] applied which mentioned in constructor.
  List<TempcordDataConvertedObject> readBytes(Uint8List bytes) =>
      _strToData(utf8.decode(lzma.decode(bytes)));

  /// More convinence [readBytes] method that returns a [Map] with declared
  /// [Type] and parsed [TempcordDataConvertedObject].
  ///
  /// Normally, there is no duplicated [Type] contains in [Map] which the data
  /// will be incompleted if applied.
  Map<Type, TempcordDataConvertedObject> readBytesWithDefinedType(
          Uint8List bytes) =>
      Map.fromEntries(readBytes(bytes).map((e) => MapEntry(e.runtimeType, e)));
}
