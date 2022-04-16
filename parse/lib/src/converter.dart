abstract class TempcordDataConverter<T> {
  const TempcordDataConverter();

  String encodeData(T data);

  T decodeData(String dataStr);
}
