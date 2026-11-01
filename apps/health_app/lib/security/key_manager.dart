import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyManager {
  static const _wrappedDbKeyName = 'wrapped_db_key';
  static const _saltName = 'pin_salt';

  final FlutterSecureStorage _storage;

  KeyManager({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final _argon2 = Argon2id(
    memory: 19 * 1024,
    parallelism: 1,
    iterations: 2,
    hashLength: 32,
  );

  Future<SecretKey> deriveKeyFromPin(String pin) async {
    final saltB64 = await _storage.read(key: _saltName);
    final salt = saltB64 == null
        ? await _createSalt()
        : base64Decode(saltB64);

    return _argon2.deriveKeyFromPassword(
      password: pin,
      nonce: salt,
    );
  }

  Future<List<int>> _createSalt() async {
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    await _storage.write(key: _saltName, value: base64Encode(salt));
    return salt;
  }

  Future<Uint8List> createAndWrapDbKey(SecretKey pinKey) async {
    final random = Random.secure();
    final dbKey = Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
    final box = await AesGcm.with256bits().encrypt(
      dbKey,
      secretKey: pinKey,
    );
    await _storage.write(
      key: _wrappedDbKeyName,
      value: base64Encode(box.concatenation()),
    );
    return dbKey;
  }

  Future<Uint8List?> unwrapDbKey(SecretKey pinKey) async {
    final stored = await _storage.read(key: _wrappedDbKeyName);
    if (stored == null) return null;
    final box = SecretBox.fromConcatenation(
      base64Decode(stored),
      nonceLength: 12,
      macLength: 16,
    );
    try {
      final clear = await AesGcm.with256bits().decrypt(box, secretKey: pinKey);
      return Uint8List.fromList(clear);
    } on SecretBoxAuthenticationError {
      return null;
    }
  }
}