import 'dart:collection';

/// Defined type that how JSON get repersented in Dart object.
typedef Json = Map<String, dynamic>;

/// A row that contains data in each index of [Csv].
typedef CsvRow = List<String>;

/// A [CsvRow] that uses for indication each [Csv] column's metadata.
typedef CsvAttribute = UnmodifiableListView<String>;

/// Define type that how CSV get repersented in Dart object.
typedef Csv = List<CsvRow>;
