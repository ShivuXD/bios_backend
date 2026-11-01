// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OperationsTable extends Operations
    with TableInfo<$OperationsTable, Operation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeIdMeta = const VerificationMeta(
    'scopeId',
  );
  @override
  late final GeneratedColumn<String> scopeId = GeneratedColumn<String>(
    'scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcPhysicalMeta = const VerificationMeta(
    'hlcPhysical',
  );
  @override
  late final GeneratedColumn<int> hlcPhysical = GeneratedColumn<int>(
    'hlc_physical',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcCounterMeta = const VerificationMeta(
    'hlcCounter',
  );
  @override
  late final GeneratedColumn<int> hlcCounter = GeneratedColumn<int>(
    'hlc_counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcNodeMeta = const VerificationMeta(
    'hlcNode',
  );
  @override
  late final GeneratedColumn<String> hlcNode = GeneratedColumn<String>(
    'hlc_node',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatVersionMeta = const VerificationMeta(
    'formatVersion',
  );
  @override
  late final GeneratedColumn<int> formatVersion = GeneratedColumn<int>(
    'format_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
    'hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signatureMeta = const VerificationMeta(
    'signature',
  );
  @override
  late final GeneratedColumn<String> signature = GeneratedColumn<String>(
    'signature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    deviceId,
    userId,
    scopeId,
    hlcPhysical,
    hlcCounter,
    hlcNode,
    entityType,
    entityId,
    payloadJson,
    formatVersion,
    hash,
    signature,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Operation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('scope_id')) {
      context.handle(
        _scopeIdMeta,
        scopeId.isAcceptableOrUnknown(data['scope_id']!, _scopeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeIdMeta);
    }
    if (data.containsKey('hlc_physical')) {
      context.handle(
        _hlcPhysicalMeta,
        hlcPhysical.isAcceptableOrUnknown(
          data['hlc_physical']!,
          _hlcPhysicalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hlcPhysicalMeta);
    }
    if (data.containsKey('hlc_counter')) {
      context.handle(
        _hlcCounterMeta,
        hlcCounter.isAcceptableOrUnknown(data['hlc_counter']!, _hlcCounterMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcCounterMeta);
    }
    if (data.containsKey('hlc_node')) {
      context.handle(
        _hlcNodeMeta,
        hlcNode.isAcceptableOrUnknown(data['hlc_node']!, _hlcNodeMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcNodeMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('format_version')) {
      context.handle(
        _formatVersionMeta,
        formatVersion.isAcceptableOrUnknown(
          data['format_version']!,
          _formatVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_formatVersionMeta);
    }
    if (data.containsKey('hash')) {
      context.handle(
        _hashMeta,
        hash.isAcceptableOrUnknown(data['hash']!, _hashMeta),
      );
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    if (data.containsKey('signature')) {
      context.handle(
        _signatureMeta,
        signature.isAcceptableOrUnknown(data['signature']!, _signatureMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  Operation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Operation(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      scopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_id'],
      )!,
      hlcPhysical: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hlc_physical'],
      )!,
      hlcCounter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hlc_counter'],
      )!,
      hlcNode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc_node'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      formatVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}format_version'],
      )!,
      hash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash'],
      )!,
      signature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signature'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $OperationsTable createAlias(String alias) {
    return $OperationsTable(attachedDatabase, alias);
  }
}

class Operation extends DataClass implements Insertable<Operation> {
  final String opId;
  final String deviceId;
  final String userId;
  final String scopeId;
  final int hlcPhysical;
  final int hlcCounter;
  final String hlcNode;
  final String entityType;
  final String entityId;
  final String payloadJson;
  final int formatVersion;
  final String hash;
  final String? signature;
  final bool synced;
  const Operation({
    required this.opId,
    required this.deviceId,
    required this.userId,
    required this.scopeId,
    required this.hlcPhysical,
    required this.hlcCounter,
    required this.hlcNode,
    required this.entityType,
    required this.entityId,
    required this.payloadJson,
    required this.formatVersion,
    required this.hash,
    this.signature,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    map['device_id'] = Variable<String>(deviceId);
    map['user_id'] = Variable<String>(userId);
    map['scope_id'] = Variable<String>(scopeId);
    map['hlc_physical'] = Variable<int>(hlcPhysical);
    map['hlc_counter'] = Variable<int>(hlcCounter);
    map['hlc_node'] = Variable<String>(hlcNode);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['format_version'] = Variable<int>(formatVersion);
    map['hash'] = Variable<String>(hash);
    if (!nullToAbsent || signature != null) {
      map['signature'] = Variable<String>(signature);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  OperationsCompanion toCompanion(bool nullToAbsent) {
    return OperationsCompanion(
      opId: Value(opId),
      deviceId: Value(deviceId),
      userId: Value(userId),
      scopeId: Value(scopeId),
      hlcPhysical: Value(hlcPhysical),
      hlcCounter: Value(hlcCounter),
      hlcNode: Value(hlcNode),
      entityType: Value(entityType),
      entityId: Value(entityId),
      payloadJson: Value(payloadJson),
      formatVersion: Value(formatVersion),
      hash: Value(hash),
      signature: signature == null && nullToAbsent
          ? const Value.absent()
          : Value(signature),
      synced: Value(synced),
    );
  }

  factory Operation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Operation(
      opId: serializer.fromJson<String>(json['opId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      userId: serializer.fromJson<String>(json['userId']),
      scopeId: serializer.fromJson<String>(json['scopeId']),
      hlcPhysical: serializer.fromJson<int>(json['hlcPhysical']),
      hlcCounter: serializer.fromJson<int>(json['hlcCounter']),
      hlcNode: serializer.fromJson<String>(json['hlcNode']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      formatVersion: serializer.fromJson<int>(json['formatVersion']),
      hash: serializer.fromJson<String>(json['hash']),
      signature: serializer.fromJson<String?>(json['signature']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'deviceId': serializer.toJson<String>(deviceId),
      'userId': serializer.toJson<String>(userId),
      'scopeId': serializer.toJson<String>(scopeId),
      'hlcPhysical': serializer.toJson<int>(hlcPhysical),
      'hlcCounter': serializer.toJson<int>(hlcCounter),
      'hlcNode': serializer.toJson<String>(hlcNode),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'formatVersion': serializer.toJson<int>(formatVersion),
      'hash': serializer.toJson<String>(hash),
      'signature': serializer.toJson<String?>(signature),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Operation copyWith({
    String? opId,
    String? deviceId,
    String? userId,
    String? scopeId,
    int? hlcPhysical,
    int? hlcCounter,
    String? hlcNode,
    String? entityType,
    String? entityId,
    String? payloadJson,
    int? formatVersion,
    String? hash,
    Value<String?> signature = const Value.absent(),
    bool? synced,
  }) => Operation(
    opId: opId ?? this.opId,
    deviceId: deviceId ?? this.deviceId,
    userId: userId ?? this.userId,
    scopeId: scopeId ?? this.scopeId,
    hlcPhysical: hlcPhysical ?? this.hlcPhysical,
    hlcCounter: hlcCounter ?? this.hlcCounter,
    hlcNode: hlcNode ?? this.hlcNode,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    payloadJson: payloadJson ?? this.payloadJson,
    formatVersion: formatVersion ?? this.formatVersion,
    hash: hash ?? this.hash,
    signature: signature.present ? signature.value : this.signature,
    synced: synced ?? this.synced,
  );
  Operation copyWithCompanion(OperationsCompanion data) {
    return Operation(
      opId: data.opId.present ? data.opId.value : this.opId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      scopeId: data.scopeId.present ? data.scopeId.value : this.scopeId,
      hlcPhysical: data.hlcPhysical.present
          ? data.hlcPhysical.value
          : this.hlcPhysical,
      hlcCounter: data.hlcCounter.present
          ? data.hlcCounter.value
          : this.hlcCounter,
      hlcNode: data.hlcNode.present ? data.hlcNode.value : this.hlcNode,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      formatVersion: data.formatVersion.present
          ? data.formatVersion.value
          : this.formatVersion,
      hash: data.hash.present ? data.hash.value : this.hash,
      signature: data.signature.present ? data.signature.value : this.signature,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Operation(')
          ..write('opId: $opId, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('scopeId: $scopeId, ')
          ..write('hlcPhysical: $hlcPhysical, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNode: $hlcNode, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('formatVersion: $formatVersion, ')
          ..write('hash: $hash, ')
          ..write('signature: $signature, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    deviceId,
    userId,
    scopeId,
    hlcPhysical,
    hlcCounter,
    hlcNode,
    entityType,
    entityId,
    payloadJson,
    formatVersion,
    hash,
    signature,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Operation &&
          other.opId == this.opId &&
          other.deviceId == this.deviceId &&
          other.userId == this.userId &&
          other.scopeId == this.scopeId &&
          other.hlcPhysical == this.hlcPhysical &&
          other.hlcCounter == this.hlcCounter &&
          other.hlcNode == this.hlcNode &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.payloadJson == this.payloadJson &&
          other.formatVersion == this.formatVersion &&
          other.hash == this.hash &&
          other.signature == this.signature &&
          other.synced == this.synced);
}

class OperationsCompanion extends UpdateCompanion<Operation> {
  final Value<String> opId;
  final Value<String> deviceId;
  final Value<String> userId;
  final Value<String> scopeId;
  final Value<int> hlcPhysical;
  final Value<int> hlcCounter;
  final Value<String> hlcNode;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> payloadJson;
  final Value<int> formatVersion;
  final Value<String> hash;
  final Value<String?> signature;
  final Value<bool> synced;
  final Value<int> rowid;
  const OperationsCompanion({
    this.opId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.scopeId = const Value.absent(),
    this.hlcPhysical = const Value.absent(),
    this.hlcCounter = const Value.absent(),
    this.hlcNode = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.formatVersion = const Value.absent(),
    this.hash = const Value.absent(),
    this.signature = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OperationsCompanion.insert({
    required String opId,
    required String deviceId,
    required String userId,
    required String scopeId,
    required int hlcPhysical,
    required int hlcCounter,
    required String hlcNode,
    required String entityType,
    required String entityId,
    required String payloadJson,
    required int formatVersion,
    required String hash,
    this.signature = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : opId = Value(opId),
       deviceId = Value(deviceId),
       userId = Value(userId),
       scopeId = Value(scopeId),
       hlcPhysical = Value(hlcPhysical),
       hlcCounter = Value(hlcCounter),
       hlcNode = Value(hlcNode),
       entityType = Value(entityType),
       entityId = Value(entityId),
       payloadJson = Value(payloadJson),
       formatVersion = Value(formatVersion),
       hash = Value(hash);
  static Insertable<Operation> custom({
    Expression<String>? opId,
    Expression<String>? deviceId,
    Expression<String>? userId,
    Expression<String>? scopeId,
    Expression<int>? hlcPhysical,
    Expression<int>? hlcCounter,
    Expression<String>? hlcNode,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? payloadJson,
    Expression<int>? formatVersion,
    Expression<String>? hash,
    Expression<String>? signature,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (deviceId != null) 'device_id': deviceId,
      if (userId != null) 'user_id': userId,
      if (scopeId != null) 'scope_id': scopeId,
      if (hlcPhysical != null) 'hlc_physical': hlcPhysical,
      if (hlcCounter != null) 'hlc_counter': hlcCounter,
      if (hlcNode != null) 'hlc_node': hlcNode,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (formatVersion != null) 'format_version': formatVersion,
      if (hash != null) 'hash': hash,
      if (signature != null) 'signature': signature,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OperationsCompanion copyWith({
    Value<String>? opId,
    Value<String>? deviceId,
    Value<String>? userId,
    Value<String>? scopeId,
    Value<int>? hlcPhysical,
    Value<int>? hlcCounter,
    Value<String>? hlcNode,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? payloadJson,
    Value<int>? formatVersion,
    Value<String>? hash,
    Value<String?>? signature,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return OperationsCompanion(
      opId: opId ?? this.opId,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      scopeId: scopeId ?? this.scopeId,
      hlcPhysical: hlcPhysical ?? this.hlcPhysical,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      hlcNode: hlcNode ?? this.hlcNode,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      payloadJson: payloadJson ?? this.payloadJson,
      formatVersion: formatVersion ?? this.formatVersion,
      hash: hash ?? this.hash,
      signature: signature ?? this.signature,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (scopeId.present) {
      map['scope_id'] = Variable<String>(scopeId.value);
    }
    if (hlcPhysical.present) {
      map['hlc_physical'] = Variable<int>(hlcPhysical.value);
    }
    if (hlcCounter.present) {
      map['hlc_counter'] = Variable<int>(hlcCounter.value);
    }
    if (hlcNode.present) {
      map['hlc_node'] = Variable<String>(hlcNode.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (formatVersion.present) {
      map['format_version'] = Variable<int>(formatVersion.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (signature.present) {
      map['signature'] = Variable<String>(signature.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OperationsCompanion(')
          ..write('opId: $opId, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('scopeId: $scopeId, ')
          ..write('hlcPhysical: $hlcPhysical, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNode: $hlcNode, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('formatVersion: $formatVersion, ')
          ..write('hash: $hash, ')
          ..write('signature: $signature, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OperationsTable operations = $OperationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [operations];
}

typedef $$OperationsTableCreateCompanionBuilder = OperationsCompanion Function({
  required String opId,
  required String deviceId,
  required String userId,
  required String scopeId,
  required int hlcPhysical,
  required int hlcCounter,
  required String hlcNode,
  required String entityType,
  required String entityId,
  required String payloadJson,
  required int formatVersion,
  required String hash,
  Value<String?> signature,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$OperationsTableUpdateCompanionBuilder = OperationsCompanion Function({
  Value<String> opId,
  Value<String> deviceId,
  Value<String> userId,
  Value<String> scopeId,
  Value<int> hlcPhysical,
  Value<int> hlcCounter,
  Value<String> hlcNode,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> payloadJson,
  Value<int> formatVersion,
  Value<String> hash,
  Value<String?> signature,
  Value<bool> synced,
  Value<int> rowid,
});

class $$OperationsTableFilterComposer
    extends Composer<_$AppDatabase, $OperationsTable> {
  $$OperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hlcPhysical => $composableBuilder(
    column: $table.hlcPhysical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlcNode => $composableBuilder(
    column: $table.hlcNode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get formatVersion => $composableBuilder(
    column: $table.formatVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $OperationsTable> {
  $$OperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hlcPhysical => $composableBuilder(
    column: $table.hlcPhysical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlcNode => $composableBuilder(
    column: $table.hlcNode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get formatVersion => $composableBuilder(
    column: $table.formatVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OperationsTable> {
  $$OperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get scopeId =>
      $composableBuilder(column: $table.scopeId, builder: (column) => column);

  GeneratedColumn<int> get hlcPhysical => $composableBuilder(
    column: $table.hlcPhysical,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hlcNode =>
      $composableBuilder(column: $table.hlcNode, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get formatVersion => $composableBuilder(
    column: $table.formatVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<String> get signature =>
      $composableBuilder(column: $table.signature, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$OperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OperationsTable,
          Operation,
          $$OperationsTableFilterComposer,
          $$OperationsTableOrderingComposer,
          $$OperationsTableAnnotationComposer,
          $$OperationsTableCreateCompanionBuilder,
          $$OperationsTableUpdateCompanionBuilder,
          (
            Operation,
            BaseReferences<_$AppDatabase, $OperationsTable, Operation>,
          ),
          Operation,
          PrefetchHooks Function()
        > {
  $$OperationsTableTableManager(_$AppDatabase db, $OperationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> scopeId = const Value.absent(),
                Value<int> hlcPhysical = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
                Value<String> hlcNode = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> formatVersion = const Value.absent(),
                Value<String> hash = const Value.absent(),
                Value<String?> signature = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperationsCompanion(
                opId: opId,
                deviceId: deviceId,
                userId: userId,
                scopeId: scopeId,
                hlcPhysical: hlcPhysical,
                hlcCounter: hlcCounter,
                hlcNode: hlcNode,
                entityType: entityType,
                entityId: entityId,
                payloadJson: payloadJson,
                formatVersion: formatVersion,
                hash: hash,
                signature: signature,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                required String deviceId,
                required String userId,
                required String scopeId,
                required int hlcPhysical,
                required int hlcCounter,
                required String hlcNode,
                required String entityType,
                required String entityId,
                required String payloadJson,
                required int formatVersion,
                required String hash,
                Value<String?> signature = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperationsCompanion.insert(
                opId: opId,
                deviceId: deviceId,
                userId: userId,
                scopeId: scopeId,
                hlcPhysical: hlcPhysical,
                hlcCounter: hlcCounter,
                hlcNode: hlcNode,
                entityType: entityType,
                entityId: entityId,
                payloadJson: payloadJson,
                formatVersion: formatVersion,
                hash: hash,
                signature: signature,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OperationsTable, Operation>(table),
                  BaseReferences<_$AppDatabase, $OperationsTable, Operation>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OperationsTable,
      Operation,
      $$OperationsTableFilterComposer,
      $$OperationsTableOrderingComposer,
      $$OperationsTableAnnotationComposer,
      $$OperationsTableCreateCompanionBuilder,
      $$OperationsTableUpdateCompanionBuilder,
      (Operation, BaseReferences<_$AppDatabase, $OperationsTable, Operation>),
      Operation,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OperationsTableTableManager get operations =>
      $$OperationsTableTableManager(_db, _db.operations);
}
