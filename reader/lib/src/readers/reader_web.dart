import 'dart:html';
import 'dart:typed_data';

import 'package:tempcord_data_parser/handlers.dart';
import 'package:tempcord_data_parser/parser.dart';

import '../parser.dart';

/// Resolve [file]'s basic read-only [TempcordDataConvertedObject] content which
/// are standarised [Profile] and [BodyTemperatureRecordListCsv].
Future<List<TempcordDataConvertedObject>> readFromFile(Object file) async {
  assert(file is File);

  final Future<Uint8List> byted = Future(() {
    late Uint8List decoded;

    FileReader reader = FileReader();
    reader.readAsArrayBuffer(file as File);
    reader.onLoad.listen((event) {
      var r = reader.result;
      decoded = r is Uint8List ? r : Uint8List.fromList(r as List<int>);
    });

    while (reader.readyState != FileReader.DONE) {}

    return decoded;
  });

  return genericParser.readBytes(await byted);
}
