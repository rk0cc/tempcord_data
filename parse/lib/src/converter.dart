abstract class TempcordDataConverter<T> {
  String encodeData(T data);

  T decodeData(String dataStr);
}
