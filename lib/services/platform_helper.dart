import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Initialize sqflite FFI for desktop platforms.
/// This file imports dart:io and is only loaded on non-web platforms.
void initDesktopDatabase() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
