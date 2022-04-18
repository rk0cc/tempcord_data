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
  ///
  /// The returned [String] should not contains a data divider from
  /// [TempcordDataParser]:
  /// ```dart
  /// const String dataDivider = "\u{241E}\u{efda}\u{e1ab}\u{e711}\u{eee4}\u{eba8}\u{ef7f}\u{eaab}\u{f781}\u{f5ad}\u{eeab}\u{ec26}\u{e780}\u{eadb}\u{ed0c}\u{f6fb}\u{f59f}\u{241E}"
  /// ```
  /// This [String] will be used to isolate various data of
  /// [TempcordDataConvertedObject] into a single byte data and it should not
  /// existed in [encodeData].
  String encodeData(TO data);

  /// Decode [dataStr] to object [TO].
  TO decodeData(String dataStr);
}
