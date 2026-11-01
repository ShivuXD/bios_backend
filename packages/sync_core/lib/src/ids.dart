import 'dart:math';

final _random = Random.secure();

String uuidV7([int? nowMs]) {
  final ms = nowMs ?? DateTime.now().millisecondsSinceEpoch;
  final bytes = List<int>.filled(16, 0);
  for (var i = 0; i < 6; i++) {
    bytes[i] = (ms >> (8 * (5 - i))) & 0xff;
  }
  for (var i = 6; i < 16; i++) {
    bytes[i] = _random.nextInt(256);
  }
  bytes[6] = (bytes[6] & 0x0f) | 0x70;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  String hex(int b) => b.toRadixString(16).padLeft(2, '0');
  final h = bytes.map(hex).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}'
      '-${h.substring(16, 20)}-${h.substring(20, 32)}';
}