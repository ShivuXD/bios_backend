import 'package:sqlite3/sqlite3.dart';

/// Server tables other than the operation log. Stored in server_meta.db.
class ServerMeta {
  final Database _db;

  ServerMeta._(this._db);

  static ServerMeta open(String path) {
    final db = sqlite3.open(path);
    db.execute('PRAGMA journal_mode = WAL;');
    db.execute('PRAGMA synchronous = FULL;');
    _createTables(db);
    return ServerMeta._(db);
  }

  static void _createTables(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS devices (
        device_id TEXT PRIMARY KEY,
        user_id TEXT,
        role TEXT,
        scope TEXT,
        public_key TEXT,
        certificate TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        enrolled_at INTEGER,
        last_seen INTEGER,
        last_counter INTEGER NOT NULL DEFAULT 0
      )
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS snapshots (
        snapshot_id TEXT PRIMARY KEY,
        up_to_seq INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        blob BLOB
      )
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS device_acks (
        device_id TEXT PRIMARY KEY,
        acked_seq INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS revocations (
        device_id TEXT PRIMARY KEY,
        revoked_at INTEGER NOT NULL,
        signed_by TEXT,
        signature TEXT
      )
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS storage_reports (
        device_id TEXT PRIMARY KEY,
        log_bytes INTEGER NOT NULL,
        percent REAL NOT NULL,
        reported_at INTEGER NOT NULL
      )
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS audit_log (
        log_id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT,
        reason TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  /// Highest sequence this device has confirmed. 0 if none.
  int ackedSeq(String deviceId) {
    final rows = _db.select(
      'SELECT acked_seq FROM device_acks WHERE device_id = ?',
      [deviceId],
    );
    return rows.isEmpty ? 0 : rows.first['acked_seq'] as int;
  }

  /// Records a confirmation. The stored value never moves backward.
  void recordAck(String deviceId, int seq) {
    _db.execute(
      '''
      INSERT INTO device_acks (device_id, acked_seq, updated_at)
      VALUES (?, ?, ?)
      ON CONFLICT(device_id) DO UPDATE SET
        acked_seq = MAX(device_acks.acked_seq, excluded.acked_seq),
        updated_at = excluded.updated_at
      ''',
      [deviceId, seq, DateTime.now().millisecondsSinceEpoch],
    );
  }

  /// Every device that has acknowledged anything, for the admin coverage view.
  List<Map<String, Object?>> allAcks() {
    final rows = _db.select(
      'SELECT device_id, acked_seq, updated_at FROM device_acks ORDER BY device_id',
    );
    return rows
        .map((r) => <String, Object?>{
              'deviceId': r['device_id'],
              'ackedSeq': r['acked_seq'],
              'updatedAt': r['updated_at'],
            })
        .toList();
  }

  /// Logs an event by id and reason only. Never write patient or student values here.
  void audit(String? deviceId, String reason) {
    _db.execute(
      'INSERT INTO audit_log (device_id, reason, timestamp) VALUES (?, ?, ?)',
      [deviceId, reason, DateTime.now().millisecondsSinceEpoch],
    );
  }

  void close() => _db.close();
}

final ServerMeta serverMeta = ServerMeta.open('server_meta.db');