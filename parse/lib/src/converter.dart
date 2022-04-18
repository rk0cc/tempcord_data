import 'package:meta/meta.dart';

/// A [Object] repersent this object can be converted between file data format
/// ([T]) and Dart object.
abstract class TempcordDataConvertedObject<T extends Object> {
  /// Alias method for returning collections [T] in this class.
  ///
  /// This method can not be called directly.
  @protected
  T toData();
}

/// Handle [TempcordDataConvertedObject] to be converted between [String] and
/// [T] with related data.
abstract class TempcordDataConverter<T extends Object,
    TO extends TempcordDataConvertedObject<T>> {
  /// Construct a converter for [TO].
  const TempcordDataConverter();

  /// Encode [data] to stringified under [T] format.
  String encodeData(TO data);

  /// Decode [dataStr] to object [TO].
  TO decodeData(String dataStr);
}
