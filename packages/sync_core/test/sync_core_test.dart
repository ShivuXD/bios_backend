import 'package:sync_core/src/hlc.dart';
import 'package:sync_core/src/ids.dart';
import 'package:sync_core/src/operation.dart';
import 'package:sync_core/src/signing.dart';
import 'package:test/test.dart';

void main() {
  test('clock never goes backward when phone time jumps back', () {
    var wall = 1000;
    final clock = HlcClock('A', now: () => wall);
    final a = clock.tick();
    final b = clock.tick();
    wall = 500;
    final c = clock.tick();
    expect(a.compareTo(b), lessThan(0));
    expect(b.compareTo(c), lessThan(0));
  });

  test('receive moves the clock past a remote timestamp', () {
    final clock = HlcClock('A', now: () => 1000);
    final remote = Hlc(5000, 3, 'B');
    final after = clock.receive(remote);
    expect(after.compareTo(remote), greaterThan(0));
  });

  test('uuidV7 IDs are unique and time-ordered', () {
    final a = uuidV7(1000);
    final b = uuidV7(2000);
    expect(a, isNot(equals(b)));
    expect(a.compareTo(b), lessThan(0));
  });

  test('operation hash is valid when untouched and fails when changed', () {
    final op = Operation.create(
      opId: uuidV7(1000),
      deviceId: 'A',
      userId: 'u1',
      scopeId: 'area-1',
      hlc: const Hlc(1000, 0, 'A'),
      entityType: 'temperature',
      entityId: 'patient-42',
      payload: {'value': 38.2},
    );
    expect(op.isHashValid, isTrue);

    final tampered = Operation.fromRow(
      opId: op.opId,
      deviceId: op.deviceId,
      userId: op.userId,
      scopeId: op.scopeId,
      hlc: op.hlc,
      entityType: op.entityType,
      entityId: op.entityId,
      payloadJson: '{"value":99.9}',
      formatVersion: op.formatVersion,
      hash: op.hash,
    );
    expect(tampered.isHashValid, isFalse);
  });

  test('signature verifies with the right key and fails with another key', () async {
    final phone = await DeviceSigner.generate();
    final other = await DeviceSigner.generate();
    const hash = 'abc123';

    final sig = await phone.sign(hash);

    expect(
      await DeviceSigner.verify(
        hash: hash,
        signatureB64: sig,
        publicKey: phone.publicKey,
      ),
      isTrue,
    );
    expect(
      await DeviceSigner.verify(
        hash: hash,
        signatureB64: sig,
        publicKey: other.publicKey,
      ),
      isFalse,
    );
  });
}