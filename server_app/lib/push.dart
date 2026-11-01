import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:sync_core/sync_core.dart';

final LocalStore serverStore = LocalStore.openInMemory();

/// Accepted edits, in the order the server accepted them.
/// Position + 1 is the server_seq, used as the pull cursor.
final List<Operation> _serverLog = [];

Map<String, Object?> _toJson(Operation op, int serverSeq) => {
      'serverSeq': serverSeq,
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
    };

Future<Response> pushHandler(Request request) async {
  final body = await request.readAsString();
  final decoded = jsonDecode(body);

  if (decoded is! Map<String, dynamic> || decoded['ops'] is! List) {
    return Response(400,
        body: jsonEncode({'error': 'body must be {"ops": [...]}'}),
        headers: {'content-type': 'application/json'});
  }

  final results = <Map<String, Object?>>[];
  for (final item in decoded['ops'] as List) {
    try {
      final map = item as Map<String, dynamic>;
      final op = Operation.fromRow(
        opId: map['opId'] as String,
        deviceId: map['deviceId'] as String,
        userId: map['userId'] as String,
        scopeId: map['scopeId'] as String,
        hlc: Hlc(
          map['hlcPhysical'] as int,
          map['hlcCounter'] as int,
          map['hlcNode'] as String,
        ),
        entityType: map['entityType'] as String,
        entityId: map['entityId'] as String,
        payloadJson: map['payloadJson'] as String,
        formatVersion: map['formatVersion'] as int,
        hash: map['hash'] as String,
      );
      final result = serverStore.insert(op, synced: true);
      if (result == InsertResult.applied) {
        _serverLog.add(op);
      }
      results.add({'opId': op.opId, 'result': result.name});
    } catch (e) {
      results.add({
        'opId': null,
        'result': 'rejectedMalformed',
        'error': e.toString(),
      });
    }
  }

  return Response.ok(
    jsonEncode({'results': results}),
    headers: {'content-type': 'application/json'},
  );
}

Response pullHandler(Request request) {
  final sinceRaw = int.tryParse(request.url.queryParameters['since'] ?? '0') ?? 0;
  final limitRaw = int.tryParse(request.url.queryParameters['limit'] ?? '100') ?? 100;
  final since = sinceRaw < 0 ? 0 : sinceRaw;
  final limit = limitRaw.clamp(1, 100);

  final slice = _serverLog.skip(since).take(limit).toList();
  final nextCursor = since + slice.length;
  final hasMore = nextCursor < _serverLog.length;

  final ops = [
    for (var i = 0; i < slice.length; i++) _toJson(slice[i], since + i + 1),
  ];

  return Response.ok(
    jsonEncode({'ops': ops, 'nextCursor': nextCursor, 'hasMore': hasMore}),
    headers: {'content-type': 'application/json'},
  );
}
int serverLatestSeq() => _serverLog.length;