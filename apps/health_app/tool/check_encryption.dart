import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:health_app/db/app_database.dart';

void main() async {
  final key = Uint8List.fromList(List<int>.generate(32, (i) => i + 1));
  final file = File('check_encrypted.db');
  if (file.existsSync()) file.deleteSync();

  final db = AppDatabase(
    NativeDatabase(
      file,
      setup: (raw) {
        raw.execute("PRAGMA key = \"x'${key.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}'\";");
      },
    ),
  );
  await db.customSelect('SELECT 1').get();
  await db.close();

  final bytes = file.readAsBytesSync();
  final header = String.fromCharCodes(bytes.take(16));
  print(header == 'SQLite format 3\u0000'
      ? 'FAIL: file is plain SQLite'
      : 'PASS: file is not plain SQLite');
}