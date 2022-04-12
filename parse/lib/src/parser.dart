import 'dart:typed_data';

import 'package:lzma/lzma.dart';
import 'package:meta/meta.dart';

import 'handlers/profile.dart';
import 'handlers/record.dart';

@sealed
class ResolvedTempcordDataResult<P extends ProfileJsonMixin,
    N extends BodyTemperatureRecordNodeCsvRowMixin> {
  final P profile;
  final BodyTemperatureRecordListCsv<N> btrl;

  ResolvedTempcordDataResult._(this.profile, this.btrl);
}

@sealed
class TempcordDataParser<P extends ProfileJsonMixin,
    N extends BodyTemperatureRecordNodeCsvRowMixin> {
  static const String _dataDivider = "";

  final ProfileJsonDataConverter<P> _profileConverter;
  final BodyTemperaturerRecordListCsvConverter<N> _btrlConverter;

  TempcordDataParser._(this._profileConverter, this._btrlConverter);

  factory TempcordDataParser(
          {required ProfileJsonDataConverter<P> profileConverter,
          required BodyTemperaturerRecordListCsvConverter<N> btrlConverter}) =>
      TempcordDataParser._(profileConverter, btrlConverter);

  Uint8List encodeBytes(P profile, BodyTemperatureRecordListCsv<N> recordList) {
    List<int> compressed = lzma.encode(Uint8List.fromList(
        "${_profileConverter.encodeData(profile)}$_dataDivider${_btrlConverter.encodeData(recordList)}"
            .codeUnits));

    return compressed is Uint8List
        ? compressed
        : Uint8List.fromList(compressed);
  }

  ResolvedTempcordDataResult<P, N> decodeBytes(Uint8List bytes) {
    List<int> decompressed = lzma.decode(bytes);

    if (!(decompressed is Uint8List)) {
      decompressed = Uint8List.fromList(decompressed);
    }

    List<String> rawData =
        String.fromCharCodes(decompressed).split(_dataDivider);

    return ResolvedTempcordDataResult._(
        _profileConverter.decodeData(rawData[0]),
        _btrlConverter.decodeData(rawData[1]));
  }
}
