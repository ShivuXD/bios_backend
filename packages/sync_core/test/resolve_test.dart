import 'dart:convert';

import 'package:sync_core/src/hlc.dart';
import 'package:sync_core/src/merge.dart';
import 'package:sync_core/src/operation.dart';
import 'package:sync_core/src/store.dart';
import 'package:test/test.dart';

Operation reading(String opId, int ms, double value) => Operation.create(
      opId: opId,
      deviceId: 'A',
      userId: 'u1',
      scopeId: 'area-1',
      hlc: Hlc(ms, 0, 'A'),
      entityType: 'temperature',
      entityId: 'patient-42',
      payload: {'takenAt': '10:00', 'value': value},
    );

LocalStore storeWithConflict() {
  final store = LocalStore.openInMemory();
  store.insert(reading('op-asha', 1000, 38.2), synced: false);
  store.insert(reading('op-ravi', 1100, 37.1), synced: false);
  return store;
}

void main() {
  test('resolving picks the chosen value, closes the conflict, and sets record ok', () {
    final store = storeWithConflict();
    final key = naturalKey(reading('x', 1000, 0));
    expect(store.openConflictCount(), 1);
    final conflictId = store.openConflicts().first['conflictId'] as int;

    store.resolveConflict(
      conflictId: conflictId,
      chosenOpId: 'op-ravi',
      resolutionOpId: 'op-resolve',
      deviceId: 'A',
      userId: 'u1',
      hlc: const Hlc(5000, 0, 'A'),
    );

    expect(store.openConflictCount(), 0);
    expect(store.recordStatus(key), 'ok');
    final value = (jsonDecode(store.recordPayload(key)!) as Map)['value'];
    expect(value, 37.1);
    expect(store.unsyncedOpIds(), contains('op-resolve'));
    store.close();
  });

  test('resolution clock must be newer than both conflicting edits', () {
    final store = storeWithConflict();
    final conflictId = store.openConflicts().first['conflictId'] as int;

    expect(
      () => store.resolveConflict(
        conflictId: conflictId,
        chosenOpId: 'op-asha',
        resolutionOpId: 'op-resolve',
        deviceId: 'A',
        userId: 'u1',
        hlc: const Hlc(500, 0, 'A'),
      ),
      throwsArgumentError,
    );
    expect(store.openConflictCount(), 1);
    store.close();
  });

  test('a conflict cannot be resolved twice', () {
    final store = storeWithConflict();
    final conflictId = store.openConflicts().first['conflictId'] as int;

    store.resolveConflict(
      conflictId: conflictId,
      chosenOpId: 'op-asha',
      resolutionOpId: 'op-resolve',
      deviceId: 'A',
      userId: 'u1',
      hlc: const Hlc(5000, 0, 'A'),
    );

    expect(
      () => store.resolveConflict(
        conflictId: conflictId,
        chosenOpId: 'op-ravi',
        resolutionOpId: 'op-resolve-2',
        deviceId: 'A',
        userId: 'u1',
        hlc: const Hlc(6000, 0, 'A'),
      ),
      throwsStateError,
    );
    store.close();
  });
}