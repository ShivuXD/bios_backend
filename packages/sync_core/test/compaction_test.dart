import 'package:sync_core/sync_core.dart';
import 'package:test/test.dart';

Operation edit(String opId, int seq, {double value = 38.2}) => Operation.create(
      opId: opId,
      deviceId: 'A',
      userId: 'u1',
      scopeId: 'area-1',
      hlc: Hlc(1000 + seq, 0, 'A'),
      entityType: 'temperature',
      entityId: 'patient-42',
      payload: {'takenAt': 'slot-$seq', 'value': value},
    );

void main() {
  test('acknowledged edits are removed, unacknowledged and unsent are kept', () {
    final store = LocalStore.openInMemory();
    for (var i = 1; i <= 5; i++) {
      store.insert(edit('op-$i', i), synced: true);
    }
    store.insert(edit('op-6', 6), synced: false);

    // Both peers have acknowledged up to sequence 3.
    final removed = store.compact(
      {'peerA': 3, 'peerB': 3},
      (opId) => int.parse(opId.split('-').last),
    );

    expect(removed, 3);
    expect(store.count(), 3);
    expect(store.unsyncedOpIds(), ['op-6']);
    store.close();
  });

  test('an edit behind an open conflict is kept even if acknowledged', () {
    final store = LocalStore.openInMemory();
    store.insert(edit('op-1', 1, value: 38.2), synced: true);
    store.insert(edit('op-2', 2, value: 37.1), synced: true);
    expect(store.openConflictCount(), 1);

    final removed = store.compact(
      {'peerA': 2},
      (opId) => int.parse(opId.split('-').last),
    );

    expect(removed, 0);
    expect(store.count(), 2);
    store.close();
  });

    test('an edit behind an open conflict is kept even if acknowledged', () {
    final store = LocalStore.openInMemory();
    store.insert(
      Operation.create(
        opId: 'op-1',
        deviceId: 'A',
        userId: 'u1',
        scopeId: 'area-1',
        hlc: const Hlc(1001, 0, 'A'),
        entityType: 'temperature',
        entityId: 'patient-42',
        payload: {'takenAt': '10:00', 'value': 38.2},
      ),
      synced: true,
    );
    store.insert(
      Operation.create(
        opId: 'op-2',
        deviceId: 'B',
        userId: 'u1',
        scopeId: 'area-1',
        hlc: const Hlc(1002, 0, 'B'),
        entityType: 'temperature',
        entityId: 'patient-42',
        payload: {'takenAt': '10:00', 'value': 37.1},
      ),
      synced: true,
    );
    expect(store.openConflictCount(), 1);

    final removed = store.compact(
      {'peerA': 2},
      (opId) => int.parse(opId.split('-').last),
    );

    expect(removed, 0);
    expect(store.count(), 2);
    store.close();
  });
}