/// A library that implement handler between file data in Dart object
/// ([Map] from [jsonDecode] and [List] from
/// [BodyTemperatureRecordListCsvConverter.csvDecoder] (pre-defined
/// [CsvToListConverter])) to [Profile] and [BodyTemperatureRecordNode] which
/// implemented with [ProfileJson] and [BodyTemperatureRecordNodeCsvRow]
/// correspondingly.
library handlers;

import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:tempcord_data_interface/interface.dart';
import 'package:tempcord_data_parser/src/handlers/profile.dart';
import 'package:tempcord_data_parser/src/handlers/record.dart';

export 'package:tempcord_data_interface/interface.dart'
    show Profile, BodyTemperatureRecordNode;
export 'package:tempcord_data_interface/type.dart';
export 'src/handlers/profile.dart' hide ProfileJsonDataConverter;
export 'src/handlers/record.dart' hide BodyTemperatureRecordListCsvConverter;
export 'src/typedef.dart';
