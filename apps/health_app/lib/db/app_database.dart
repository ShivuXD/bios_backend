import 'package:drift/drift.dart';

part 'app_database.g.dart';

class Operations extends Table {
  TextColumn get opId => text()();
  TextColumn get deviceId => text()();
  TextColumn get userId => text()();
  TextColumn get scopeId => text()();
  IntColumn get hlcPhysical => integer()();
  IntColumn get hlcCounter => integer()();
  TextColumn get hlcNode => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get payloadJson => text()();
  IntColumn get formatVersion => integer()();
  TextColumn get hash => text()();
  TextColumn get signature => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {opId};
}

@DriftDatabase(tables: [Operations])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}