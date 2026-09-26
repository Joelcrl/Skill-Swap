import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/match.dart';
import '../models/swipe.dart';

/// Cooldown between completed swaps with the same partner before they can
/// swap (and rate) each other again. Tweak this constant for local testing —
/// e.g. `Duration(minutes: 1)` to verify the rematch flow without waiting.
const Duration kReSwapCooldown = Duration(days: 7);

class SwipeResult {
  const SwipeResult({
    required this.matchCreated,
    this.matchId,
    this.existingMatchActive = false,
  });

  final bool matchCreated;
  final String? matchId;

  /// True when this swipe ran into a not-yet-completed existing match
  /// (matched / inProgress). The deck just bounces straight into that match
  /// instead of pretending nothing happened.
  final bool existingMatchActive;
}

class ReSwapTooSoonException implements Exception {
  const ReSwapTooSoonException(this.remaining);
  final Duration remaining;

  @override
  String toString() {
    final days = remaining.inDays;
    if (days >= 1) return 'You can swap with this person again in $days day${days == 1 ? '' : 's'}.';
    final hours = remaining.inHours;
    if (hours >= 1) return 'You can swap with this person again in $hours hour${hours == 1 ? '' : 's'}.';
    final minutes = remaining.inMinutes;
    return 'You can swap with this person again in $minutes minute${minutes == 1 ? '' : 's'}.';
  }
}

class SwipeService {
  SwipeService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _swipes =>
      _firestore.collection('swipes');
  CollectionReference<Map<String, dynamic>> get _matches =>
      _firestore.collection('matches');

  /// Latest match doc (highest round number) between the two users, or null.
  Future<Match?> _latestMatchBetween(String a, String b) async {
    final snap = await _matches.where('userIds', arrayContains: a).get();
    Match? latest;
    for (final doc in snap.docs) {
      final ids = (doc.data()['userIds'] as List?)?.cast<String>() ?? const [];
      if (!ids.contains(b)) continue;
      final m = Match.fromFirestore(doc);
      if (latest == null || m.roundNumber > latest.roundNumber) latest = m;
    }
    return latest;
  }

  Future<SwipeResult> swipe({
    required String myUid,
    required String otherUid,
    required SwipeDirection direction,
  }) async {
    final latest = await _latestMatchBetween(myUid, otherUid);

    // Decide which round this swipe belongs to.
    int targetRound;
    if (latest == null) {
      targetRound = 1;
    } else if (latest.state == MatchState.completed) {
      final completedAt = latest.updatedAt;
      if (completedAt != null) {
        final age = DateTime.now().difference(completedAt);
        if (age < kReSwapCooldown) {
          throw ReSwapTooSoonException(kReSwapCooldown - age);
        }
      }
      targetRound = latest.roundNumber + 1;
    } else {
      // Active match (matched / inProgress) — don't create more swipes,
      // just point the deck at the existing match.
      return SwipeResult(
        matchCreated: false,
        matchId: latest.id,
        existingMatchActive: true,
      );
    }

    final mySwipe = Swipe(
      swiperUid: myUid,
      swipedUid: otherUid,
      direction: direction,
      createdAt: null,
      roundNumber: targetRound,
    );
    await _swipes
        .doc(Swipe.idFor(myUid, otherUid, round: targetRound))
        .set(mySwipe.toCreateMap());

    if (direction != SwipeDirection.like) {
      return const SwipeResult(matchCreated: false);
    }

    final matchId = Match.idFor(myUid, otherUid, round: targetRound);
    final matchRef = _matches.doc(matchId);
    final otherSwipeRef = _swipes
        .doc(Swipe.idFor(otherUid, myUid, round: targetRound));

    return _firestore.runTransaction<SwipeResult>((tx) async {
      final otherSwipeDoc = await tx.get(otherSwipeRef);
      if (!otherSwipeDoc.exists) {
        return const SwipeResult(matchCreated: false);
      }
      final otherDir = otherSwipeDoc.data()?['direction'] as String?;
      if (otherDir != 'like') {
        return const SwipeResult(matchCreated: false);
      }

      final matchDoc = await tx.get(matchRef);
      if (matchDoc.exists) {
        return SwipeResult(matchCreated: false, matchId: matchId);
      }

      final sortedIds = [myUid, otherUid]..sort();
      tx.set(matchRef, {
        'userIds': sortedIds,
        'state': 'matched',
        'turnsCompleted': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'roundNumber': targetRound,
      });
      return SwipeResult(matchCreated: true, matchId: matchId);
    });
  }
}
