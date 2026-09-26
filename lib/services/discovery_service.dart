import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';
import 'swipe_service.dart';

class _PartnerLatest {
  const _PartnerLatest({
    required this.round,
    required this.state,
    required this.updatedAt,
  });
  final int round;
  final String? state;
  final DateTime? updatedAt;
}

class DiscoveryService {
  DiscoveryService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<List<UserProfile>> fetchCandidates({
    required String currentUid,
    int batchSize = 25,
  }) async {
    final usersSnap = await _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(batchSize * 2)
        .get();
    final candidates = usersSnap.docs
        .where((d) => d.id != currentUid)
        .map(UserProfile.fromFirestore)
        .toList();

    // Build a map of partnerUid -> latest match info between us.
    final myMatchesSnap = await _firestore
        .collection('matches')
        .where('userIds', arrayContains: currentUid)
        .get();
    final partnerLatest = <String, _PartnerLatest>{};
    for (final doc in myMatchesSnap.docs) {
      final data = doc.data();
      final ids = (data['userIds'] as List?)?.cast<String>() ?? const [];
      final partner = ids.firstWhere(
        (id) => id != currentUid,
        orElse: () => '',
      );
      if (partner.isEmpty) continue;
      final round = (data['roundNumber'] as int?) ?? 1;
      final existing = partnerLatest[partner];
      if (existing == null || round > existing.round) {
        partnerLatest[partner] = _PartnerLatest(
          round: round,
          state: data['state'] as String?,
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
        );
      }
    }

    // Group my swipes by partner -> max round.
    final mySwipesSnap = await _firestore
        .collection('swipes')
        .where('swiperUid', isEqualTo: currentUid)
        .get();
    final partnerSwipeRound = <String, int>{};
    for (final doc in mySwipesSnap.docs) {
      final data = doc.data();
      final swiped = data['swipedUid'] as String?;
      if (swiped == null) continue;
      final round = (data['roundNumber'] as int?) ?? 1;
      final cur = partnerSwipeRound[swiped] ?? 0;
      if (round > cur) partnerSwipeRound[swiped] = round;
    }

    final now = DateTime.now();

    return candidates.where((u) {
      final latest = partnerLatest[u.uid];
      int eligibleRound;
      if (latest == null) {
        eligibleRound = 1;
      } else if (latest.state == 'completed') {
        // Cooldown gate: if not yet eligible, hide them.
        final completedAt = latest.updatedAt;
        if (completedAt != null) {
          final age = now.difference(completedAt);
          if (age < kReSwapCooldown) return false;
        }
        eligibleRound = latest.round + 1;
      } else {
        // Active match (matched / inProgress) — they live in "Your swaps",
        // not the discovery deck.
        return false;
      }
      final mySwipeRound = partnerSwipeRound[u.uid] ?? 0;
      // If I've already swiped them in the current/eligible round, hide.
      return mySwipeRound < eligibleRound;
    }).take(batchSize).toList();
  }
}
