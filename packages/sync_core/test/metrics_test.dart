import 'dart:convert';

import 'package:sync_core/src/hlc.dart';
import 'package:sync_core/src/operation.dart';
import 'package:sync_core/src/store.dart';
import 'package:sync_core/src/sync.dart';
import 'package:test/test.dart';

Operation op(String opId, int ms) => Operation.create(
      opId: opId,
      deviceId: 'A',
      userId: 'u1',
      scopeId: 'area-1',
      hlc: Hlc(ms, 0, 'A'),
      entityType: 'temperature',
      entityId: 'patient-42',
      payload: {'takenAt': 'slot-$ms', 'value': 38.2},
    );

void main() {
  test('report bytes sent per sync against a full copy', () {
    final a = LocalStore.openInMemory();
    final b = LocalStore.openInMemory();
    for (var i = 0; i < 2000; i++) {
      a.insert(op('op-$i', 1000 + i), synced: false);
    }

    final pending = a.pendingOperations();
    final syncBytes = utf8.encode(pending.map((o) => o.payloadJson).join('\n')).length;
    final fullBytes = utf8.encode(
      a.pendingOperations().map((o) => o.payloadJson).join('\n'),
    ).length;

    SyncSession(sender: a, receiver: b).run(); // first sync sends everything
    a.insert(op('op-new', 9999), synced: false); // one new edit later
    final pendingNow = a.pendingOperations();
    final deltaBytes = utf8.encode(
      pendingNow.map((o) => o.payloadJson).join('\n'),
    ).length;

    print('full copy bytes: $fullBytes');
    print('delta bytes after one new edit: $deltaBytes');
    print('delta as percent of full copy: ${(deltaBytes * 100 / fullBytes).toStringAsFixed(2)}%');
    expect(deltaBytes, lessThan(fullBytes / 10));
    expect(syncBytes, greaterThan(0));
    a.close();
    b.close();
  });
}