import 'dart:convert';
import 'dart:typed_data';

import 'package:lzma/lzma.dart';
import 'package:meta/meta.dart';

import 'converter.dart';
import 'handlers/profile.dart';
import 'handlers/record.dart';

typedef GenericTempcordDataConverter
    = TempcordDataConverter<Object, TempcordDataConvertedObject<Object>>;

@sealed
class TempcordDataParser<P extends ProfileJson,
    N extends BodyTemperatureRecordNodeCsvRow> {
  static const String _dataDivider = "\u{241E}";

  final List<GenericTempcordDataConverter> _converters;

  TempcordDataParser._(this._converters);

  factory TempcordDataParser(
          {required ProfileJsonDataConverter<P> profileConverter,
          required BodyTemperatureRecordListCsvConverter<N> btrlConverter,
          List<GenericTempcordDataConverter>? additionalConverter}) =>
      TempcordDataParser._(<GenericTempcordDataConverter>[
        profileConverter,
        btrlConverter
      ]..addAll(additionalConverter ?? <GenericTempcordDataConverter>[]));

  String _dataToStr(List<TempcordDataConvertedObject> datas) {
    assert(datas.length == _converters.length,
        "Provided data length must be the same with the applied converter");

    List<String> dataStr = [];
    for (int i = 0; i < _converters.length; i++) {
      dataStr.add(_converters[i].encodeData(datas[i]));
    }

    return dataStr.join(_dataDivider);
  }

  List<TempcordDataConvertedObject> _strToData(String str) {
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
          List<TempcordDataConvertedObject<Object>>? addition}) =>
      UnmodifiableUint8ListView(Uint8List.fromList(lzma.encode(utf8.encode(
          _dataToStr(<TempcordDataConvertedObject>[profile, btr]
            ..addAll(addition ?? <TempcordDataConvertedObject>[]))))));

  List<TempcordDataConvertedObject> readBytes(Uint8List bytes) =>
      _strToData(utf8.decode(lzma.decode(bytes)));
}
