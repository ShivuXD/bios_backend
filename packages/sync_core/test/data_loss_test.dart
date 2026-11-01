import 'dart:math';

import 'package:sync_core/src/hlc.dart';
import 'package:sync_core/src/operation.dart';
import 'package:sync_core/src/store.dart';
import 'package:test/test.dart';

void main() {
  test('random edits, duplicates and shuffled order lose nothing', () {
    const runs = 200;
    const editsPerRun = 50;

    for (var seed = 0; seed < runs; seed++) {
      final rng = Random(seed);
      final store = LocalStore.openInMemory();

      final created = <Operation>[];
      for (var i = 0; i < editsPerRun; i++) {
        final op = Operation.create(
          opId: 'op-$seed-$i',
          deviceId: 'device-${rng.nextInt(3)}',
          userId: 'u1',
          scopeId: 'area-1',
          hlc: Hlc(1000 + i, 0, 'device-${rng.nextInt(3)}'),
          entityType: 'temperature',
          entityId: 'patient-${rng.nextInt(5)}',
          payload: {'takenAt': 'slot-$i', 'value': 36.0 + rng.nextInt(40) / 10},
        );
        created.add(op);
      }

      // Each edit is sent once or more, in shuffled order.
      final delivered = [...created, ...created.take(editsPerRun ~/ 3)]
        ..shuffle(rng);

      var applied = 0;
      var duplicate = 0;
      for (final op in delivered) {
        final result = store.insert(op, synced: false);
        if (result == InsertResult.applied) applied++;
        if (result == InsertResult.duplicate) duplicate++;
      }

      expect(applied, editsPerRun, reason: 'seed $seed: lost edits');
      expect(duplicate, editsPerRun ~/ 3,
          reason: 'seed $seed: wrong duplicate count');
      expect(store.count(), editsPerRun, reason: 'seed $seed: stored count');
      store.close();
    }
  });
}