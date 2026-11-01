import 'package:sync_core/src/hlc.dart';
import 'package:sync_core/src/operation.dart';
import 'package:sync_core/src/restore.dart';
import 'package:sync_core/src/store.dart';
import 'package:sync_core/src/sync.dart';
import 'package:test/test.dart';

Operation edit(String deviceId, String opId, int ms) => Operation.create(
      opId: opId,
      deviceId: deviceId,
      userId: 'u1',
      scopeId: 'area-1',
      hlc: Hlc(ms, 0, deviceId),
      entityType: 'temperature',
      entityId: 'patient-42',
      payload: {'takenAt': 'slot-$ms', 'value': 37.0 + ms % 5},
    );

void main() {
  test('a replacement phone restores a lost phone\'s edits from a peer', () {
    // Phone A makes edits and syncs them to phone B, then is lost.
    final a = LocalStore.openInMemory();
    final b = LocalStore.openInMemory();
    for (var i = 0; i < 5; i++) {
      a.insert(edit('A', 'a-$i', 1000 + i), synced: false);
    }
    SyncSession(sender: a, receiver: b).run();
    final lostEdits = a.editsByDevice('A');
    a.close(); // phone A is gone

    // Peer B holds A's edits. Replacement phone C asks B for them.
    final restoredFromPeer = b.editsByDevice('A');
    final c = LocalStore.openInMemory();
    for (final op in restoredFromPeer) {
      c.insert(op, synced: true);
    }

    expect(restoredFromPeer.length, lostEdits.length);
    expect(c.editsByDevice('A').map((o) => o.opId).toList(),
        lostEdits.map((o) => o.opId).toList());
    b.close();
    c.close();
  });
}