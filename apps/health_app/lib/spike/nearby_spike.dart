import 'dart:convert';
import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

const String _serviceId = 'com.example.health_app.spike';
const Strategy _strategy = Strategy.P2P_CLUSTER;

class NearbySpike {
  final String phoneName;
  final void Function(String) onLog;
  final void Function(String endpointId, String text) onMessage;
  final List<String> connectedIds = [];

  NearbySpike({
    required this.phoneName,
    required this.onLog,
    required this.onMessage,
  });

  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.nearbyWifiDevices,
      Permission.location,
    ].request();
    final granted = statuses.values.every((s) => s.isGranted);
    onLog(granted ? 'permissions granted' : 'permissions missing');
    return granted;
  }

  Future<void> start() async {
    await Nearby().startAdvertising(
      phoneName,
      _strategy,
      serviceId: _serviceId,
      onConnectionInitiated: _onInitiated,
      onConnectionResult: (id, status) {
        onLog('connection $id: $status');
        if (status == Status.CONNECTED && !connectedIds.contains(id)) {
          connectedIds.add(id);
        }
      },
      onDisconnected: (id) {
        connectedIds.remove(id);
        onLog('disconnected $id');
      },
    );
    onLog('advertising as $phoneName');

    await Nearby().startDiscovery(
      phoneName,
      _strategy,
      serviceId: _serviceId,
      onEndpointFound: (id, name, serviceId) {
        onLog('found $name');
        Nearby().requestConnection(
          phoneName,
          id,
          onConnectionInitiated: _onInitiated,
          onConnectionResult: (id, status) {
            onLog('connection $id: $status');
            if (status == Status.CONNECTED && !connectedIds.contains(id)) {
              connectedIds.add(id);
            }
          },
          onDisconnected: (id) {
            connectedIds.remove(id);
            onLog('disconnected $id');
          },
        );
      },
      onEndpointLost: (id) => onLog('lost $id'),
    );
    onLog('discovering');
  }

  void _onInitiated(String id, ConnectionInfo info) {
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (endpointId, payload) {
        final bytes = payload.bytes;
        if (bytes == null) return;
        onMessage(endpointId, utf8.decode(bytes));
      },
    );
  }

  Future<void> sendHello(String endpointId, String text) async {
    await Nearby().sendBytesPayload(
      endpointId,
      Uint8List.fromList(utf8.encode(text)),
    );
    onLog('sent to $endpointId: $text');
  }

  Future<void> stop() async {
    await Nearby().stopAllEndpoints();
    await Nearby().stopAdvertising();
    await Nearby().stopDiscovery();
    connectedIds.clear();
    onLog('stopped');
  }
}