import 'dart:math';

class Hlc implements Comparable<Hlc> {
  final int physical;
  final int counter;
  final String nodeId;

  const Hlc(this.physical, this.counter, this.nodeId);

  @override
  int compareTo(Hlc other) {
    if (physical != other.physical) return physical.compareTo(other.physical);
    if (counter != other.counter) return counter.compareTo(other.counter);
    return nodeId.compareTo(other.nodeId);
  }

  @override
  String toString() => '$physical:$counter:$nodeId';
}

class HlcClock {
  final String nodeId;
  final int Function() _now;
  int _physical;
  int _counter;

  HlcClock(this.nodeId, {int Function()? now, int physical = 0, int counter = 0})
      : _now = now ?? (() => DateTime.now().millisecondsSinceEpoch),
        _physical = physical,
        _counter = counter;

  Hlc tick() {
    final wall = _now();
    if (wall > _physical) {
      _physical = wall;
      _counter = 0;
    } else {
      _counter++;
    }
    return Hlc(_physical, _counter, nodeId);
  }

  Hlc receive(Hlc remote) {
    final wall = _now();
    final maxPhys = max(wall, max(_physical, remote.physical));

    if (maxPhys == _physical && maxPhys == remote.physical) {
      _counter = max(_counter, remote.counter) + 1;
    } else if (maxPhys == _physical) {
      _counter++;
    } else if (maxPhys == remote.physical) {
      _counter = remote.counter + 1;
    } else {
      _counter = 0;
    }
    _physical = maxPhys;
    return Hlc(_physical, _counter, nodeId);
  }

  int get physical => _physical;
  int get counter => _counter;
}