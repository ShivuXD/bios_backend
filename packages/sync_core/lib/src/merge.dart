import 'dart:convert';

import 'operation.dart';

/// Decides which edits describe the same fact.
/// Two edits with the same key and different payloads are a conflict.
String naturalKey(Operation op) {
  switch (op.entityType) {
    case 'temperature':
      return _key(op, ['takenAt']);
    case 'attendance':
      return _key(op, ['session', 'date']);
    case 'allergy':
      return _key(op, ['allergen']);
    default:
      throw ArgumentError.value(op.entityType, 'entityType', 'no merge rule');
  }
}

String _key(Operation op, List<String> fields) {
  final payload = jsonDecode(op.payloadJson) as Map<String, dynamic>;
  final parts = <String>[op.entityType, op.entityId];
  for (final field in fields) {
    final value = payload[field];
    if (value == null) {
      throw ArgumentError.value(field, 'payload', 'missing key field');
    }
    parts.add('$field=$value');
  }
  return parts.join('|');
}