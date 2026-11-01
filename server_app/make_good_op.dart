import 'dart:convert';
import 'dart:io';

import 'package:sync_core/sync_core.dart';

void main() {
  final op = Operation.create(
    opId: 'srv-2',
    deviceId: 'A',
    userId: 'u1',
    scopeId: 'area-1',
    hlc: const Hlc(2000, 0, 'A'),
    entityType: 'temperature',
    entityId: 'patient-42',
    payload: {'takenAt': '11:00', 'value': 38.2},
  );
  final body = jsonEncode({
    'ops': [
      {
        'opId': op.opId,
        'deviceId': op.deviceId,
        'userId': op.userId,
        'scopeId': op.scopeId,
        'hlcPhysical': op.hlc.physical,
        'hlcCounter': op.hlc.counter,
        'hlcNode': op.hlc.nodeId,
        'entityType': op.entityType,
        'entityId': op.entityId,
        'payloadJson': op.payloadJson,
        'formatVersion': op.formatVersion,
        'hash': op.hash,
      }
    ]
  });
  File('push_good.json').writeAsStringSync(body);
  print('wrote push_good.json');
}