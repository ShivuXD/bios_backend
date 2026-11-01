import 'dart:convert';

import 'package:cryptography/cryptography.dart';

class DeviceSigner {
  final SimpleKeyPair _keyPair;
  final SimplePublicKey publicKey;

  DeviceSigner._(this._keyPair, this.publicKey);

  static Future<DeviceSigner> generate() async {
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final pub = await keyPair.extractPublicKey();
    return DeviceSigner._(keyPair, pub);
  }

  Future<String> sign(String hash) async {
    final signature = await Ed25519().sign(
      utf8.encode(hash),
      keyPair: _keyPair,
    );
    return base64Encode(signature.bytes);
  }

  static Future<bool> verify({
    required String hash,
    required String signatureB64,
    required SimplePublicKey publicKey,
  }) async {
    final signature = Signature(
      base64Decode(signatureB64),
      publicKey: publicKey,
    );
    return Ed25519().verify(utf8.encode(hash), signature: signature);
  }
}