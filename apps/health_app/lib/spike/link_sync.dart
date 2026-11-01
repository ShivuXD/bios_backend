import 'dart:convert';

import 'package:sync_core/sync_core.dart';

/// Sends and receives real edits over the Nearby link, using the sync_core store.
class LinkSync {
  final LocalStore store;
  final String deviceId;
  final void Function(String) onLog;
  final void Function(String endpointId, String text) send;
  int _counter = 0;

  LinkSync({
    required this.store,
    required this.deviceId,
    required this.onLog,
    required this.send,
  });

  /// Creates one new temperature edit on this phone.
  void addEdit() {
    _counter++;
    final ms = DateTime.now().millisecondsSinceEpoch;
    final op = Operation.create(
      opId: '$deviceId-$ms-$_counter',
      deviceId: deviceId,
      userId: 'u1',
      scopeId: 'area-1',
      hlc: Hlc(ms, 0, deviceId),
      entityType: 'temperature',
      entityId: 'patient-42',
      payload: {'takenAt': '$ms', 'value': 37.0 + (ms % 30) / 10},
    );
    final result = store.insert(op, synced: false);
    onLog('added ${op.opId}: ${result.name}');
  }

  /// Sends every edit this phone has not sent yet.
  void sendPending(String endpointId) {
    final ops = store.pendingOperations();
    if (ops.isEmpty) {
      onLog('nothing to send');
      return;
    }
    final msg = jsonEncode({
      'type': 'ops',
      'ops': [for (final op in ops) _toJson(op)],
    });
    send(endpointId, msg);
    onLog('sent ${ops.length} edit(s) to $endpointId');
  }

  /// Asks a peer for every edit it holds from a lost device.
  void requestRestore(String endpointId, String lostDeviceId) {
    send(endpointId, jsonEncode({'type': 'restore', 'deviceId': lostDeviceId}));
    onLog('asked $endpointId for $lostDeviceId edits');
  }

  /// Handles an incoming message: stores edits, acks them, answers restore requests,
  /// or applies restored edits.
  void onText(String endpointId, String text) {
    Map<String, dynamic> msg;
    try {
      msg = jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      onLog('not an edit message');
      return;
    }

    final type = msg['type'];
    if (type == 'ops') {
      final received = <String>[];
      for (final item in msg['ops'] as List) {
        try {
          final op = _fromJson(item as Map<String, dynamic>);
          final result = store.insert(op, synced: true);
          if (result == InsertResult.applied ||
              result == InsertResult.duplicate) {
            received.add(op.opId);
          }
          onLog('got ${op.opId}: ${result.name}');
        } catch (e) {
          onLog('rejected an edit: $e');
        }
      }
      send(endpointId, jsonEncode({'type': 'ack', 'opIds': received}));
    } else if (type == 'ack') {
      final ids = (msg['opIds'] as List).cast<String>();
      for (final id in ids) {
        store.markSynced(id);
      }
      onLog('confirmed ${ids.length} edit(s)');
    } else if (type == 'restore') {
      final lostId = msg['deviceId'] as String;
      final ops = store.editsByDevice(lostId);
      send(endpointId, jsonEncode({
        'type': 'restore_ops',
        'ops': [for (final op in ops) _toJson(op)],
      }));
      onLog('sent ${ops.length} edit(s) of $lostId for restore');
    } else if (type == 'restore_ops') {
      var stored = 0;
      for (final item in msg['ops'] as List) {
        final op = _fromJson(item as Map<String, dynamic>);
        if (store.insert(op, synced: true) == InsertResult.applied) {
          stored++;
        }
      }
      onLog('restored $stored edit(s)');
    }
  }

  Map<String, Object?> _toJson(Operation op) => {
        'opId': op.opId,
        'deviceId': op.deviceId,
        'userId': op.userId,
        'scopeId': op.scopeId,
        'hlcPhysical': op.hlc.physical,
        'hlcCounter': op.hlc.counter,
        'hlcNode': op.hlc.nodeId,
        'entityType': op.entityType,
        'entityId': op.entityId,
        'payloadJson': op.payloadJson,
        'formatVersion': op.formatVersion,
        'hash': op.hash,
      };

  Operation _fromJson(Map<String, dynamic> m) => Operation.fromRow(
        opId: m['opId'] as String,
        deviceId: m['deviceId'] as String,
        userId: m['userId'] as String,
        scopeId: m['scopeId'] as String,
        hlc: Hlc(
          m['hlcPhysical'] as int,
          m['hlcCounter'] as int,
          m['hlcNode'] as String,
        ),
        entityType: m['entityType'] as String,
        entityId: m['entityId'] as String,
        payloadJson: m['payloadJson'] as String,
        formatVersion: m['formatVersion'] as int,
        hash: m['hash'] as String,
      );
}