import 'dart:typed_data';

abstract class TempcordDataConverter<T> {
  String encodeData(T data);

  T decodeData(String dataStr);
}
