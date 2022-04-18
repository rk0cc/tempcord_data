import 'dart:io';

import 'package:tempcord_data_parser/handlers.dart';
import 'package:tempcord_data_parser/parser.dart';

import '../parser.dart';

/// Resolve [file]'s basic read-only [TempcordDataConvertedObject] content which
/// are standarised [Profile] and [BodyTemperatureRecordListCsv].
Future<List<TempcordDataConvertedObject>> readFromFile(Object file) async {
  assert(file is File);

  return genericParser.readBytes(await (file as File).readAsBytes());
}
