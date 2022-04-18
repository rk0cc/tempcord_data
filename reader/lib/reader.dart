library reader;

export 'src/readers/reader_generic.dart'
    if (dart.library.io) "src/readers/reader_vm.dart"
    if (dart.library.html) "src/readers/reader_web.dart";
