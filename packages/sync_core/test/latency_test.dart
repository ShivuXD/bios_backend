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
  test('time to converge two stores after 2000 edits (simulated, not network)', () {
    final a = LocalStore.openInMemory();
    final b = LocalStore.openInMemory();
    for (var i = 0; i < 2000; i++) {
      a.insert(op('op-$i', 1000 + i), synced: false);
    }

    final watch = Stopwatch()..start();
    final applied = SyncSession(sender: a, receiver: b).run();
    watch.stop();

    print('edits applied: $applied');
    print('time to converge: ${watch.elapsedMilliseconds} ms (simulated, in memory)');
    expect(applied, 2000);
    expect(b.count(), 2000);
    expect(watch.elapsed.inSeconds, lessThan(10));
    a.close();
    b.close();
  });
}