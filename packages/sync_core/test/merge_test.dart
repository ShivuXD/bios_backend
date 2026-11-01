import 'package:sync_core/src/hlc.dart';
import 'package:sync_core/src/merge.dart';
import 'package:sync_core/src/operation.dart';
import 'package:sync_core/src/store.dart';
import 'package:test/test.dart';

Operation op(
  String opId,
  String type,
  String entityId,
  Map<String, Object?> payload, {
  int ms = 1000,
}) =>
    Operation.create(
      opId: opId,
      deviceId: 'A',
      userId: 'u1',
      scopeId: 'area-1',
      hlc: Hlc(ms, 0, 'A'),
      entityType: type,
      entityId: entityId,
      payload: payload,
    );

void main() {
  test('two temperature readings at different times are both kept, no conflict', () {
    final store = LocalStore.openInMemory();
    final a = op('op-1', 'temperature', 'patient-42',
        {'takenAt': '09:00', 'value': 37.0});
    final b = op('op-2', 'temperature', 'patient-42',
        {'takenAt': '10:00', 'value': 38.2});
    store.insert(a, synced: false);
    store.insert(b, synced: false);
    expect(store.openConflictCount(), 0);
    expect(store.recordStatus(naturalKey(a)), 'ok');
    expect(store.recordStatus(naturalKey(b)), 'ok');
    store.close();
  });

  test('two temperatures at the same time with different values are flagged', () {
    final store = LocalStore.openInMemory();
    final asha = op('op-1', 'temperature', 'patient-42',
        {'takenAt': '10:00', 'value': 38.2});
    final ravi = op('op-2', 'temperature', 'patient-42',
        {'takenAt': '10:00', 'value': 37.1});
    store.insert(asha, synced: false);
    store.insert(ravi, synced: false);
    expect(store.recordStatus(naturalKey(asha)), 'flagged');
    expect(store.openConflictCount(), 1);
    store.close();
  });

  test('same temperature at the same time from two phones is merged, no conflict', () {
    final store = LocalStore.openInMemory();
    final asha = op('op-1', 'temperature', 'patient-42',
        {'takenAt': '10:00', 'value': 38.2});
    final ravi = op('op-2', 'temperature', 'patient-42',
        {'takenAt': '10:00', 'value': 38.2});
    store.insert(asha, synced: false);
    store.insert(ravi, synced: false);
    expect(store.recordStatus(naturalKey(asha)), 'ok');
    expect(store.openConflictCount(), 0);
    expect(store.count(), 2);
    store.close();
  });

  test('same student, same session and date, different presence is flagged', () {
    final store = LocalStore.openInMemory();
    final present = op('op-1', 'attendance', 'student-7',
        {'session': 'morning', 'date': '2026-11-01', 'present': true});
    final absent = op('op-2', 'attendance', 'student-7',
        {'session': 'morning', 'date': '2026-11-01', 'present': false});
    store.insert(present, synced: false);
    store.insert(absent, synced: false);
    expect(store.recordStatus(naturalKey(present)), 'flagged');
    expect(store.openConflictCount(), 1);
    store.close();
  });

  test('same allergy with a different severity is flagged, never auto-merged', () {
    final store = LocalStore.openInMemory();
    final mild = op('op-1', 'allergy', 'patient-42',
        {'allergen': 'penicillin', 'severity': 'mild'});
    final severe = op('op-2', 'allergy', 'patient-42',
        {'allergen': 'penicillin', 'severity': 'severe'});
    store.insert(mild, synced: false);
    store.insert(severe, synced: false);
    expect(store.recordStatus(naturalKey(mild)), 'flagged');
    expect(store.openConflictCount(), 1);
    store.close();
  });

  test('a temperature without takenAt is rejected with an error', () {
    final store = LocalStore.openInMemory();
    final bad = op('op-1', 'temperature', 'patient-42', {'value': 38.2});
    expect(() => store.insert(bad, synced: false), throwsArgumentError);
    expect(store.count(), 0);
    store.close();
  });
}