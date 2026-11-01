import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';

import 'hlc.dart';
import 'merge.dart';
import 'operation.dart';

enum InsertResult { applied, duplicate, rejectedHashMismatch, rejectedBadHash }

class LocalStore {
  final Database _db;

  LocalStore._(this._db);

  static LocalStore openInMemory() {
    final db = sqlite3.openInMemory();
    _createTables(db);
    return LocalStore._(db);
  }

  static void _createTables(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS operations (
        op_id TEXT PRIMARY KEY,
        device_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        scope_id TEXT NOT NULL,
        hlc_physical INTEGER NOT NULL,
        hlc_counter INTEGER NOT NULL,
        hlc_node TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        format_version INTEGER NOT NULL,
        hash TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS records (
        record_key TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        scope_id TEXT NOT NULL,
        op_id TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'ok'
      )
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS conflicts (
        conflict_id INTEGER PRIMARY KEY AUTOINCREMENT,
        record_key TEXT NOT NULL,
        op_id_existing TEXT NOT NULL,
        op_id_incoming TEXT NOT NULL,
        resolved INTEGER NOT NULL DEFAULT 0,
        resolved_by_op_id TEXT
      )
    ''');
  }

  /// Stores an edit and applies the merge rule, in one transaction.
  InsertResult insert(Operation op, {required bool synced}) {
    if (!op.isHashValid) return InsertResult.rejectedBadHash;

    final existing = _db.select(
      'SELECT hash FROM operations WHERE op_id = ?',
      [op.opId],
    );
    if (existing.isNotEmpty) {
      final storedHash = existing.first['hash'] as String;
      return storedHash == op.hash
          ? InsertResult.duplicate
          : InsertResult.rejectedHashMismatch;
    }

    final key = naturalKey(op); // throws before any write if a key field is missing

    _inTransaction(() {
      _insertRow(op, synced: synced);
      _applyRule(op, key);
    });
    return InsertResult.applied;
  }

  /// Edits made on this phone that no peer has confirmed yet, in time order.
  List<String> unsyncedOpIds() {
    final rows = _db.select(
      'SELECT op_id FROM operations WHERE synced = 0 ORDER BY hlc_physical, hlc_counter',
    );
    return rows.map((r) => r['op_id'] as String).toList();
  }

  /// Full edits this phone has not sent yet, in time order.
  List<Operation> pendingOperations() {
    final rows = _db.select(
      'SELECT * FROM operations WHERE synced = 0 ORDER BY hlc_physical, hlc_counter',
    );
    return rows.map(_rowToOperation).toList();
  }

  void markSynced(String opId) {
    _inTransaction(() {
      _db.execute('UPDATE operations SET synced = 1 WHERE op_id = ?', [opId]);
    });
  }

  int count() {
    final rows = _db.select('SELECT COUNT(*) AS n FROM operations');
    return rows.first['n'] as int;
  }

  String? recordStatus(String recordKey) {
    final rows = _db.select(
      'SELECT status FROM records WHERE record_key = ?',
      [recordKey],
    );
    return rows.isEmpty ? null : rows.first['status'] as String;
  }

  /// The current value of a record, as JSON text. Null if the record does not exist.
  String? recordPayload(String recordKey) {
    final rows = _db.select(
      'SELECT payload_json FROM records WHERE record_key = ?',
      [recordKey],
    );
    return rows.isEmpty ? null : rows.first['payload_json'] as String;
  }

  int openConflictCount() {
    final rows = _db.select(
      'SELECT COUNT(*) AS n FROM conflicts WHERE resolved = 0',
    );
    return rows.first['n'] as int;
  }

  /// Open conflicts, for the conflict screen to show both values.
  List<Map<String, Object?>> openConflicts() {
    final rows = _db.select(
      'SELECT conflict_id, record_key, op_id_existing, op_id_incoming '
      'FROM conflicts WHERE resolved = 0 ORDER BY conflict_id',
    );
    return rows
        .map((r) => <String, Object?>{
              'conflictId': r['conflict_id'],
              'recordKey': r['record_key'],
              'opIdExisting': r['op_id_existing'],
              'opIdIncoming': r['op_id_incoming'],
            })
        .toList();
  }

  /// Resolves an open conflict by choosing one of its two edits.
  /// Writes a resolution edit with a clock newer than both conflicting edits,
  /// sets the record to that value with status ok, and closes the conflict.
  /// All of it happens in one transaction.
  void resolveConflict({
    required int conflictId,
    required String chosenOpId,
    required String resolutionOpId,
    required String deviceId,
    required String userId,
    required Hlc hlc,
  }) {
    _inTransaction(() {
      final rows = _db.select(
        'SELECT record_key, op_id_existing, op_id_incoming, resolved '
        'FROM conflicts WHERE conflict_id = ?',
        [conflictId],
      );
      if (rows.isEmpty) {
        throw StateError('conflict $conflictId does not exist');
      }
      final row = rows.first;
      if ((row['resolved'] as int) == 1) {
        throw StateError('conflict $conflictId is already resolved');
      }

      final recordKey = row['record_key'] as String;
      final existingOp = _operationById(row['op_id_existing'] as String);
      final incomingOp = _operationById(row['op_id_incoming'] as String);

      if (chosenOpId != existingOp.opId && chosenOpId != incomingOp.opId) {
        throw ArgumentError.value(
          chosenOpId,
          'chosenOpId',
          'must be one of the two conflicting edits',
        );
      }
      if (hlc.compareTo(existingOp.hlc) <= 0 ||
          hlc.compareTo(incomingOp.hlc) <= 0) {
        throw ArgumentError.value(
          hlc,
          'hlc',
          'resolution clock must be newer than both conflicting edits',
        );
      }

      final chosen = chosenOpId == existingOp.opId ? existingOp : incomingOp;
      final resolution = Operation.create(
        opId: resolutionOpId,
        deviceId: deviceId,
        userId: userId,
        scopeId: chosen.scopeId,
        hlc: hlc,
        entityType: chosen.entityType,
        entityId: chosen.entityId,
        payload: jsonDecode(chosen.payloadJson) as Map<String, Object?>,
      );

      _insertRow(resolution, synced: false);
      _db.execute(
        'UPDATE records SET op_id = ?, payload_json = ?, status = ? WHERE record_key = ?',
        [resolution.opId, resolution.payloadJson, 'ok', recordKey],
      );
      _db.execute(
        'UPDATE conflicts SET resolved = 1, resolved_by_op_id = ? WHERE conflict_id = ?',
        [resolution.opId, conflictId],
      );
    });
  }

    /// Every stored edit, in time order. Used for restore and tests.
  List<Operation> allOperations() {
    final rows = _db.select(
      'SELECT * FROM operations ORDER BY hlc_physical, hlc_counter',
    );
    return rows.map(_rowToOperation).toList();
  }

    /// True if an open conflict still points to this edit. Such edits must be kept.
  bool isReferencedByOpenConflict(String opId) {
    final rows = _db.select(
      'SELECT COUNT(*) AS n FROM conflicts WHERE resolved = 0 AND (op_id_existing = ? OR op_id_incoming = ?)',
      [opId, opId],
    );
    return (rows.first['n'] as int) > 0;
  }

  /// Deletes the given edits. Returns how many were removed.
  int deleteOperations(List<String> opIds) {
    var removed = 0;
    _inTransaction(() {
      for (final id in opIds) {
        _db.execute('DELETE FROM operations WHERE op_id = ? AND synced = 1', [id]);
        removed += _db.select('SELECT changes() AS n').first['n'] as int;
      }
    });
    return removed;
  }
  
  void close() => _db.close();

  void _insertRow(Operation op, {required bool synced}) {
    _db.execute(
      '''
      INSERT INTO operations (
        op_id, device_id, user_id, scope_id,
        hlc_physical, hlc_counter, hlc_node,
        entity_type, entity_id, payload_json,
        format_version, hash, synced
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        op.opId,
        op.deviceId,
        op.userId,
        op.scopeId,
        op.hlc.physical,
        op.hlc.counter,
        op.hlc.nodeId,
        op.entityType,
        op.entityId,
        op.payloadJson,
        op.formatVersion,
        op.hash,
        synced ? 1 : 0,
      ],
    );
  }

  Operation _operationById(String opId) {
    final rows = _db.select('SELECT * FROM operations WHERE op_id = ?', [opId]);
    if (rows.isEmpty) {
      throw StateError('operation $opId not found');
    }
    return _rowToOperation(rows.first);
  }

  Operation _rowToOperation(Row r) => Operation.fromRow(
        opId: r['op_id'] as String,
        deviceId: r['device_id'] as String,
        userId: r['user_id'] as String,
        scopeId: r['scope_id'] as String,
        hlc: Hlc(
          r['hlc_physical'] as int,
          r['hlc_counter'] as int,
          r['hlc_node'] as String,
        ),
        entityType: r['entity_type'] as String,
        entityId: r['entity_id'] as String,
        payloadJson: r['payload_json'] as String,
        formatVersion: r['format_version'] as int,
        hash: r['hash'] as String,
      );

  void _applyRule(Operation op, String key) {
    final rows = _db.select(
      'SELECT op_id, payload_json FROM records WHERE record_key = ?',
      [key],
    );

    if (rows.isEmpty) {
      _db.execute(
        '''
        INSERT INTO records (
          record_key, entity_type, entity_id, scope_id,
          op_id, payload_json, status
        ) VALUES (?, ?, ?, ?, ?, ?, 'ok')
        ''',
        [key, op.entityType, op.entityId, op.scopeId, op.opId, op.payloadJson],
      );
      return;
    }

    final stored = rows.first;
    if (stored['payload_json'] as String == op.payloadJson) {
      return; // same fact, same value: merged
    }

    _db.execute(
      "UPDATE records SET status = 'flagged' WHERE record_key = ?",
      [key],
    );
    _db.execute(
      '''
      INSERT INTO conflicts (record_key, op_id_existing, op_id_incoming)
      VALUES (?, ?, ?)
      ''',
      [key, stored['op_id'] as String, op.opId],
    );
  }

  void _inTransaction(void Function() work) {
    _db.execute('BEGIN IMMEDIATE');
    try {
      work();
      _db.execute('COMMIT');
    } catch (_) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }
}