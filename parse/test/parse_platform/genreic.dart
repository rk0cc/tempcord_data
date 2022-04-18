import 'package:tempcord_data_parser/handlers.dart';
import 'package:tempcord_data_parser/parser.dart';

import '../mock/mock_btr.dart';
import '../mock/mock_profile.dart';

void testOnPlatform(TempcordDataParser<MockProfile, MockBTRN> mockParser,
    MockProfile mp, BodyTemperatureRecordListCsv<MockBTRN> mbtrns) {
  throw UnsupportedError("This platform can not be executed");
}
