import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

Future<AppDatabase> openEncryptedDatabase(Uint8List dbKey) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/health.db');
  final hexKey = dbKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  return AppDatabase(
    NativeDatabase(
      file,
      setup: (rawDb) {
        rawDb.execute("PRAGMA key = \"x'$hexKey'\";");
      },
    ),
  );
}