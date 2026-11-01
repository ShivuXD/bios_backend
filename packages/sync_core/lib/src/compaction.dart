import 'store.dart';

/// Removes edits that every known peer has acknowledged.
/// Never removes unacknowledged edits, or edits that an open conflict still points to.
extension Compaction on LocalStore {
  int compact(Map<String, int> ackedSeqByPeer, int Function(String opId) seqOf) {
    if (ackedSeqByPeer.isEmpty) return 0;
    final safeBelow = ackedSeqByPeer.values.reduce((a, b) => a < b ? a : b);
    final removable = allOperations().where((op) {
      final seq = seqOf(op.opId);
      return seq > 0 && seq <= safeBelow && !isReferencedByOpenConflict(op.opId);
    }).map((op) => op.opId).toList();
    return deleteOperations(removable);
  }
}