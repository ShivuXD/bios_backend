import 'package:sync_core/src/hlc.dart';
import 'package:sync_core/src/operation.dart';
import 'package:sync_core/src/store.dart';
import 'package:sync_core/src/sync.dart';
import 'package:test/test.dart';

Operation op(String opId, int ms, {double value = 38.2}) => Operation.create(
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
  test('phone A sends all edits to phone B', () {
    final a = LocalStore.openInMemory();
    final b = LocalStore.openInMemory();
    for (var i = 0; i < 250; i++) {
      a.insert(op('op-$i', 1000 + i), synced: false);
    }

    final applied = SyncSession(sender: a, receiver: b).run();

    expect(applied, 250);
    expect(b.count(), 250);
    expect(a.unsyncedOpIds(), isEmpty);
    a.close();
    b.close();
  });

  test('link cut midway, then resumed: nothing lost, nothing duplicated', () {
    final a = LocalStore.openInMemory();
    final b = LocalStore.openInMemory();
    for (var i = 0; i < 250; i++) {
      a.insert(op('op-$i', 1000 + i), synced: false);
    }

    final session = SyncSession(sender: a, receiver: b);
    final firstTry = session.run(linkCutAfterChunks: 1);
    expect(firstTry, 100);
    expect(b.count(), 100);

    final secondTry = session.run();
    expect(secondTry, 150);
    expect(b.count(), 250);
    expect(a.unsyncedOpIds(), isEmpty);
    a.close();
    b.close();
  });

  test('resending the same batch after a cut adds nothing new', () {
    final a = LocalStore.openInMemory();
    final b = LocalStore.openInMemory();
    for (var i = 0; i < 50; i++) {
      a.insert(op('op-$i', 1000 + i), synced: false);
    }

       final session = SyncSession(sender: a, receiver: b);
    session.run();
    final again = session.run();
    expect(again, 0);
    expect(b.count(), 50);
    a.close();
    b.close();
  });
}