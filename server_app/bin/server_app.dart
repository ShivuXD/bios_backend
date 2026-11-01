import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import '../lib/push.dart';
import '../lib/server_db.dart';

Future<Response> helloHandler(Request request) async {
  final body = await request.readAsString();
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic> || decoded['deviceId'] is! String) {
    return Response(400,
        body: jsonEncode({'error': 'body must include deviceId'}),
        headers: {'content-type': 'application/json'});
  }
  return Response.ok(
    jsonEncode({
      'serverTimeMs': DateTime.now().millisecondsSinceEpoch,
      'latestSeq': serverLatestSeq(),
      'protocolVersion': 1,
    }),
    headers: {'content-type': 'application/json'},
  );
}

Future<Response> ackHandler(Request request) async {
  final body = await request.readAsString();
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic> ||
      decoded['deviceId'] is! String ||
      decoded['ackedSeq'] is! int) {
    return Response(400,
        body: jsonEncode({'error': 'body must include deviceId and ackedSeq'}),
        headers: {'content-type': 'application/json'});
  }
  final deviceId = decoded['deviceId'] as String;
  final ackedSeq = decoded['ackedSeq'] as int;
  serverMeta.recordAck(deviceId, ackedSeq);
  return Response.ok(
    jsonEncode({'deviceId': deviceId, 'ackedSeq': serverMeta.ackedSeq(deviceId)}),
    headers: {'content-type': 'application/json'},
  );
}

Response coverageHandler(Request request) {
  final rows = serverMeta.allAcks();
  final latest = serverLatestSeq();
  final devices = [
    for (final row in rows)
      {
        'deviceId': row['deviceId'],
        'ackedSeq': row['ackedSeq'],
        'lastUpdatedMs': row['updatedAt'],
        'latestSeq': latest,
        'unsyncedOnServer': latest - (row['ackedSeq'] as int),
      }
  ];
  return Response.ok(
    jsonEncode({'devices': devices, 'serverLatestSeq': latest}),
    headers: {'content-type': 'application/json'},
  );
}

void main() async {
  final router = Router()
    ..get('/health', (Request request) {
      return Response.ok('OK', headers: {'content-type': 'text/plain'});
    })
    ..post('/sync/hello', helloHandler)
    ..post('/sync/push', pushHandler)
    ..get('/sync/pull', pullHandler)
    ..post('/sync/ack', ackHandler)
    ..get('/admin/coverage', coverageHandler);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await shelf_io.serve(router.call, InternetAddress.anyIPv4, port);
  print('Server listening on http://localhost:${server.port}');
}