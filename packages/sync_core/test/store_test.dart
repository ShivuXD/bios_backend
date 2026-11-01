import 'package:sync_core/src/hlc.dart';
import 'package:sync_core/src/operation.dart';
import 'package:sync_core/src/store.dart';
import 'package:test/test.dart';

Operation makeOp(String opId, int ms, {double value = 38.2}) =>
    Operation.create(
      opId: opId,
      deviceId: 'A',
      userId: 'u1',
      scopeId: 'area-1',
      hlc: Hlc(ms, 0, 'A'),
      entityType: 'temperature',
      entityId: 'patient-42',
      payload: {'takenAt': 'slot-$ms', 'value': value},
    );

void main() {
  test('same operation saved twice is stored once', () {
    final store = LocalStore.openInMemory();
    final op = makeOp('op-1', 1000);
    expect(store.insert(op, synced: false), InsertResult.applied);
    expect(store.insert(op, synced: false), InsertResult.duplicate);
    expect(store.count(), 1);
    store.close();
  });

  test('outbox lists unsynced edits, and markSynced removes them', () {
    final store = LocalStore.openInMemory();
    store.insert(makeOp('op-1', 1000), synced: false);
    store.insert(makeOp('op-2', 2000), synced: false);
    expect(store.unsyncedOpIds(), ['op-1', 'op-2']);

    store.markSynced('op-1');
    expect(store.unsyncedOpIds(), ['op-2']);
    store.close();
  });

  test('same op_id with different content is rejected', () {
    final store = LocalStore.openInMemory();
    final original = makeOp('op-1', 1000);
    final changed = makeOp('op-1', 1000, value: 99.9);
    expect(store.insert(original, synced: false), InsertResult.applied);
    expect(
        store.insert(changed, synced: false), InsertResult.rejectedHashMismatch);
    expect(store.count(), 1);
    store.close();
  });

  test('operation with a broken hash is rejected', () {
    final store = LocalStore.openInMemory();
    final op = makeOp('op-1', 1000);
    final broken = Operation.fromRow(
      opId: op.opId,
      deviceId: op.deviceId,
      userId: op.userId,
      scopeId: op.scopeId,
      hlc: op.hlc,
      entityType: op.entityType,
      entityId: op.entityId,
      payloadJson: '{"takenAt":"slot-1000","value":99.9}',
      formatVersion: op.formatVersion,
      hash: op.hash,
    );
    expect(store.insert(broken, synced: false), InsertResult.rejectedBadHash);
    expect(store.count(), 0);
    store.close();
  });
}