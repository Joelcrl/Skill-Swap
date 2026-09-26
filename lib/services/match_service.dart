import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/match.dart';

class MatchService {
  MatchService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _matches =>
      _firestore.collection('matches');

  Stream<List<Match>> streamMyMatches({required String myUid}) {
    return _matches
        .where('userIds', arrayContains: myUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Match.fromFirestore).toList());
  }

  Stream<Match?> streamMatch({required String matchId}) {
    return _matches.doc(matchId).snapshots().map(
          (doc) => doc.exists ? Match.fromFirestore(doc) : null,
        );
  }

  Future<void> markMyTurnComplete({
    required String matchId,
    required String myUid,
  }) {
    final ref = _matches.doc(matchId);
    return _firestore.runTransaction<void>((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw StateError('Match not found.');
      }
      final m = Match.fromFirestore(snap);
      if (!m.isMember(myUid)) {
        throw StateError('You are not part of this match.');
      }
      if (m.didTurn(myUid)) {
        return;
      }
      final newTurns = [...m.turnsCompleted, myUid];
      final newState = newTurns.length >= 2
          ? MatchState.completed
          : MatchState.inProgress;
      tx.update(ref, {
        'turnsCompleted': newTurns,
        'state': newState.wireValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
