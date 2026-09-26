import 'package:cloud_firestore/cloud_firestore.dart';

enum MatchState {
  matched('matched'),
  inProgress('inProgress'),
  completed('completed');

  const MatchState(this.wireValue);
  final String wireValue;

  static MatchState parse(String? raw) {
    return MatchState.values.firstWhere(
      (s) => s.wireValue == raw,
      orElse: () => MatchState.matched,
    );
  }
}

class Match {
  const Match({
    required this.id,
    required this.userIds,
    required this.state,
    required this.turnsCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.roundNumber = 1,
  });

  final String id;
  final List<String> userIds;
  final MatchState state;
  final List<String> turnsCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Sequence number for repeat swaps with the same partner. Round 1 docs use
  /// the legacy `<sortedA>_<sortedB>` id; round 2+ append `_r<N>`.
  final int roundNumber;

  bool isMember(String uid) => userIds.contains(uid);
  bool didTurn(String uid) => turnsCompleted.contains(uid);
  String otherUid(String myUid) =>
      userIds.firstWhere((u) => u != myUid, orElse: () => '');

  static String idFor(String uidA, String uidB, {int round = 1}) {
    final sorted = [uidA, uidB]..sort();
    final base = '${sorted[0]}_${sorted[1]}';
    return round <= 1 ? base : '${base}_r$round';
  }

  factory Match.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Match(
      id: doc.id,
      userIds: (data['userIds'] as List?)?.cast<String>() ?? const [],
      state: MatchState.parse(data['state'] as String?),
      turnsCompleted:
          (data['turnsCompleted'] as List?)?.cast<String>() ?? const [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      roundNumber: (data['roundNumber'] as int?) ?? 1,
    );
  }
}
