import 'package:tempcord_data_parser/handlers.dart';
import 'package:tempcord_data_parser/src/typedef.dart';

class MockBTRN implements BodyTemperatureRecordNodeCsvRow {
  @override
  final Temperature temperature;

  @override
  final DateTime recordedAt;

  MockBTRN(this.temperature, DateTime recordedAt)
      : this.recordedAt = recordedAt.toUtc();

  factory MockBTRN.fromCsvRow(CsvRow row) => MockBTRN(
      Temperature.parse(value: row[0], symbol: row[1]), DateTime.parse(row[2]));

  @override
  CsvRow toCsvRow() => [
        temperature.value.toString(),
        temperature.unit,
        recordedAt.toIso8601String()
      ];
}

class OversizedMockBTRN extends MockBTRN {
  final int stuff;

  OversizedMockBTRN(Temperature temperature, DateTime recordedAt, this.stuff)
      : super(temperature, recordedAt);

  @override
  CsvRow toCsvRow() => super.toCsvRow()..add(stuff.toString());
}
