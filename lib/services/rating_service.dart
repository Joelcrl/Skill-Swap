import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/rating.dart';

class RatingAggregate {
  const RatingAggregate({required this.average, required this.count});
  final double average;
  final int count;

  static const empty = RatingAggregate(average: 0, count: 0);
}

class RatingService {
  RatingService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ratings =>
      _firestore.collection('ratings');

  Stream<Rating?> streamMyRatingForMatch({
    required String matchId,
    required String raterUid,
  }) {
    final id = Rating.idFor(matchId: matchId, raterUid: raterUid);
    return _ratings.doc(id).snapshots().map(
          (doc) => doc.exists ? Rating.fromFirestore(doc) : null,
        );
  }

  // Client-side aggregation. Cheap so long as a user has tens of ratings,
  // not thousands. Phase 5B (Cloud Functions, Blaze plan) would replace this
  // with denormalized `rating`/`ratingCount` fields on the user doc.
  Stream<RatingAggregate> streamAggregateForUser(String ratedUid) {
    return _ratings
        .where('ratedUid', isEqualTo: ratedUid)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return RatingAggregate.empty;
      var sum = 0;
      for (final d in snap.docs) {
        sum += (d.data()['stars'] as num?)?.toInt() ?? 0;
      }
      final count = snap.docs.length;
      return RatingAggregate(average: sum / count, count: count);
    });
  }

  Future<void> submitRating({
    required String matchId,
    required String raterUid,
    required String ratedUid,
    required int stars,
    required String note,
  }) {
    if (stars < 1 || stars > 5) {
      throw ArgumentError.value(stars, 'stars', 'must be 1..5');
    }
    final trimmedNote = note.trim();
    if (trimmedNote.length > 500) {
      throw ArgumentError.value(
          trimmedNote.length, 'note.length', 'must be <= 500');
    }
    final id = Rating.idFor(matchId: matchId, raterUid: raterUid);
    return _ratings.doc(id).set({
      'matchId': matchId,
      'raterUid': raterUid,
      'ratedUid': ratedUid,
      'stars': stars,
      'note': trimmedNote,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
