import 'operation.dart';
import 'store.dart';

/// Edits made by one device, in time order. Used to restore a lost phone from a peer.
extension RestoreFromPeer on LocalStore {
  List<Operation> editsByDevice(String deviceId) {
    return allOperations().where((op) => op.deviceId == deviceId).toList()
      ..sort((a, b) => a.hlc.compareTo(b.hlc));
  }
}