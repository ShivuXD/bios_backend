import 'store.dart';
import 'operation.dart';

/// One message the phones exchange. Same shape over any link.
class ChunkMessage {
  final List<Operation> ops;
  const ChunkMessage(this.ops);
}

/// Sends the edits the other phone does not have yet, in chunks.
/// A chunk counts as delivered only after the receiver confirms it.
/// If the link cuts, the next call resumes from the first unconfirmed chunk.
class SyncSession {
  final LocalStore sender;
  final LocalStore receiver;
  final int chunkSize;

  SyncSession({
    required this.sender,
    required this.receiver,
    this.chunkSize = 100,
  });

  /// Sends pending edits. `linkCutAfterChunks` simulates a dropped link:
  /// the transfer stops after that many chunks. Null means no cut.
  /// Returns how many edits the receiver newly applied.
  int run({int? linkCutAfterChunks}) {
    final pending = sender.pendingOperations();
    var applied = 0;
    var chunksSent = 0;

    for (var start = 0; start < pending.length; start += chunkSize) {
      if (linkCutAfterChunks != null && chunksSent >= linkCutAfterChunks) {
        break;
      }
      final end = (start + chunkSize).clamp(0, pending.length);
      final chunk = ChunkMessage(pending.sublist(start, end));

      for (final op in chunk.ops) {
        final result = receiver.insert(op, synced: true);
        if (result == InsertResult.applied) applied++;
      }

      // Receiver confirmed the whole chunk, so the sender marks it sent.
      for (final op in chunk.ops) {
        sender.markSynced(op.opId);
      }
      chunksSent++;
    }
    return applied;
  }
}