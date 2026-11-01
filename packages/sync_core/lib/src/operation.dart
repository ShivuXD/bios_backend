import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'hlc.dart';

const int currentFormatVersion = 1;

/// Sorted-key JSON. The same data always gives the same text, so the same hash.
String canonicalJson(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((k) => k.toString()).toList()..sort();
    final parts = keys.map((k) => '${jsonEncode(k)}:${canonicalJson(value[k])}');
    return '{${parts.join(',')}}';
  }
  if (value is List) {
    return '[${value.map(canonicalJson).join(',')}]';
  }
  return jsonEncode(value);
}

class Operation {
  final String opId;
  final String deviceId;
  final String userId;
  final String scopeId;
  final Hlc hlc;
  final String entityType;
  final String entityId;
  final String payloadJson;
  final int formatVersion;
  final String hash;

  Operation._({
    required this.opId,
    required this.deviceId,
    required this.userId,
    required this.scopeId,
    required this.hlc,
    required this.entityType,
    required this.entityId,
    required this.payloadJson,
    required this.formatVersion,
    required this.hash,
  });

  factory Operation.create({
    required String opId,
    required String deviceId,
    required String userId,
    required String scopeId,
    required Hlc hlc,
    required String entityType,
    required String entityId,
    required Map<String, Object?> payload,
  }) {
    _requireId('opId', opId);
    _requireId('deviceId', deviceId);
    _requireId('userId', userId);
    _requireId('scopeId', scopeId);
    _requireId('entityType', entityType);
    _requireId('entityId', entityId);

    final payloadJson = canonicalJson(payload);
    final hash = _hashOf(opId, deviceId, userId, scopeId, hlc, entityType,
        entityId, payloadJson, currentFormatVersion);

    return Operation._(
      opId: opId,
      deviceId: deviceId,
      userId: userId,
      scopeId: scopeId,
      hlc: hlc,
      entityType: entityType,
      entityId: entityId,
      payloadJson: payloadJson,
      formatVersion: currentFormatVersion,
      hash: hash,
    );
  }

  /// Rebuilds an operation from a stored or received row.
  /// The payload is re-canonicalized, so the hash check works on any peer's text.
  factory Operation.fromRow({
    required String opId,
    required String deviceId,
    required String userId,
    required String scopeId,
    required Hlc hlc,
    required String entityType,
    required String entityId,
    required String payloadJson,
    required int formatVersion,
    required String hash,
  }) {
    _requireId('opId', opId);
    _requireId('deviceId', deviceId);
    _requireId('userId', userId);
    _requireId('scopeId', scopeId);
    _requireId('entityType', entityType);
    _requireId('entityId', entityId);

    if (formatVersion != currentFormatVersion) {
      throw ArgumentError.value(
          formatVersion, 'formatVersion', 'unsupported format version');
    }

    final decoded = _decodeObject(payloadJson);

    return Operation._(
      opId: opId,
      deviceId: deviceId,
      userId: userId,
      scopeId: scopeId,
      hlc: hlc,
      entityType: entityType,
      entityId: entityId,
      payloadJson: canonicalJson(decoded),
      formatVersion: formatVersion,
      hash: hash,
    );
  }

  bool get isHashValid => hash == _hashOf(opId, deviceId, userId, scopeId, hlc,
      entityType, entityId, payloadJson, formatVersion);

  static void _requireId(String name, String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, name, 'must not be empty');
    }
  }

  static Map<String, dynamic> _decodeObject(String text) {
    Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw ArgumentError.value(text, 'payloadJson', 'is not valid JSON');
    }
    if (decoded is! Map<String, dynamic>) {
      throw ArgumentError.value(text, 'payloadJson', 'must be a JSON object');
    }
    return decoded;
  }

  static String _hashOf(
    String opId,
    String deviceId,
    String userId,
    String scopeId,
    Hlc hlc,
    String entityType,
    String entityId,
    String payloadJson,
    int formatVersion,
  ) {
    final envelope = canonicalJson({
      'opId': opId,
      'deviceId': deviceId,
      'userId': userId,
      'scopeId': scopeId,
      'hlc': hlc.toString(),
      'entityType': entityType,
      'entityId': entityId,
      'payload': payloadJson,
      'formatVersion': formatVersion,
    });
    return sha256.convert(utf8.encode(envelope)).toString();
  }
}