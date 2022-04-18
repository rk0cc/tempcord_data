import 'package:meta/meta.dart';

abstract class TempcordDataConvertedObject<T extends Object> {
  @protected
  T toData();
}

abstract class TempcordDataConverter<T extends Object,
    TO extends TempcordDataConvertedObject<T>> {
  const TempcordDataConverter();

  String encodeData(TO data);

  TO decodeData(String dataStr);
}
