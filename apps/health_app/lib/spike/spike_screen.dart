import 'package:flutter/material.dart';
import 'package:sync_core/sync_core.dart';

import 'link_sync.dart';
import 'nearby_spike.dart';

class SpikeScreen extends StatefulWidget {
  const SpikeScreen({super.key});

  @override
  State<SpikeScreen> createState() => _SpikeScreenState();
}

class _SpikeScreenState extends State<SpikeScreen> {
  final List<String> _log = [];
  final LocalStore _store = LocalStore.openInMemory();
  late final String _name;
  late final NearbySpike _spike;
  late final LinkSync _link;
  final TextEditingController _lostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name = 'phone-${DateTime.now().millisecondsSinceEpoch % 100000}';
    _spike = NearbySpike(
      phoneName: _name,
      onLog: (line) => setState(() => _log.add(line)),
      onMessage: (endpointId, text) => _link.onText(endpointId, text),
    );
    _link = LinkSync(
      store: _store,
      deviceId: _name,
      onLog: (line) => setState(() => _log.add(line)),
      send: (id, text) {
        _spike.sendHello(id, text);
      },
    );
  }

  @override
  void dispose() {
    _lostController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final ok = await _spike.requestPermissions();
    if (!ok) return;
    await _spike.start();
  }

  void _sendEdits() {
    if (_spike.connectedIds.isEmpty) {
      setState(() => _log.add('no connected phones yet'));
      return;
    }
    for (final id in _spike.connectedIds) {
      _link.sendPending(id);
    }
  }

  void _restore() {
    final lost = _lostController.text.trim();
    if (lost.isEmpty) {
      setState(() => _log.add('type the lost phone name first'));
      return;
    }
    if (_spike.connectedIds.isEmpty) {
      setState(() => _log.add('no connected phones yet'));
      return;
    }
    for (final id in _spike.connectedIds) {
      _link.requestRestore(id, lost);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stored = _store.count();
    final unsent = _store.unsyncedOpIds().length;
    return Scaffold(
      appBar: AppBar(title: Text('Sync test: $_name')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('stored: $stored   unsent: $unsent'),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _start, child: const Text('Start')),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => setState(() => _link.addEdit()),
              child: const Text('Add edit'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _sendEdits,
              child: const Text('Send edits'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _lostController,
              decoration: const InputDecoration(
                labelText: 'Lost phone name (for restore)',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _restore,
              child: const Text('Restore from peer'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _spike.stop(),
              child: const Text('Stop'),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: _log.reversed.map((l) => Text(l)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}