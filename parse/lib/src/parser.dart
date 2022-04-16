import 'dart:convert';
import 'dart:typed_data';

import 'package:lzma/lzma.dart';
import 'package:meta/meta.dart';

import 'converter.dart';
import 'handlers/profile.dart';
import 'handlers/record.dart';

@sealed
class TempcordDataParser<P extends ProfileJson,
    N extends BodyTemperatureRecordNodeCsvRow> {
  static const String _dataDivider = "\u{241E}";

  final List<TempcordDataConverter<Object>> _converters;

  TempcordDataParser._(this._converters);

  factory TempcordDataParser(
          {required ProfileJsonDataConverter<P> profileConverter,
          required BodyTemperatureRecordListCsvConverter<N> btrlConverter,
          List<TempcordDataConverter<Object>>? additionalConverter}) =>
      TempcordDataParser._(<TempcordDataConverter<Object>>[
        profileConverter,
        btrlConverter
      ]..addAll(additionalConverter ?? <TempcordDataConverter<Object>>[]));

  String _dataToStr(List<Object> datas) {
    assert(datas.length == _converters.length,
        "Provided data length must be the same with the applied converter");

    List<String> dataStr = [];
    for (int i = 0; i < _converters.length; i++) {
      dataStr.add(_converters[i].encodeData(datas[i]));
    }

    return dataStr.join(_dataDivider);
  }

  List<Object> _strToData(String str) {
    List<String> spiltedData = str.split(_dataDivider);

    assert(spiltedData.length == _converters.length,
        "Data sections and converters counts must be equal in this parser");

    List<Object> dataObj = [];
    for (int i = 0; i < _converters.length; i++) {
      dataObj.add(_converters[i].decodeData(spiltedData[i]));
    }

    return List.unmodifiable(dataObj);
  }

  Uint8List writeBytes(
          {required P profile,
          required BodyTemperatureRecordListCsv<N> btr,
          List<Object>? addition}) =>
      UnmodifiableUint8ListView(Uint8List.fromList(lzma.encode(utf8.encode(
          _dataToStr(
              <Object>[profile, btr]..addAll(addition ?? <Object>[]))))));

  List<Object> readBytes(Uint8List bytes) =>
      _strToData(utf8.decode(lzma.decode(bytes)));
}
