import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/rating.dart';
import '../services/rating_service.dart';
export '../services/rating_service.dart' show RatingAggregate;
import 'auth_providers.dart';
import 'profile_providers.dart';

final ratingServiceProvider = Provider<RatingService>((ref) {
  ref.keepAlive();
  return RatingService(firestore: ref.watch(firestoreProvider));
});

class MyRatingArgs {
  const MyRatingArgs({required this.matchId, required this.raterUid});
  final String matchId;
  final String raterUid;

  @override
  bool operator ==(Object other) =>
      other is MyRatingArgs &&
      other.matchId == matchId &&
      other.raterUid == raterUid;

  @override
  int get hashCode => Object.hash(matchId, raterUid);
}

// See chat_providers.dart: autoDispose + re-subscribe when the uid changes.
final myRatingForMatchProvider =
    StreamProvider.autoDispose.family<Rating?, MyRatingArgs>((ref, args) {
  final uid = ref.watch(authStateProvider.select((a) => a.value?.uid));
  if (uid == null) return const Stream.empty();
  return ref.watch(ratingServiceProvider).streamMyRatingForMatch(
        matchId: args.matchId,
        raterUid: args.raterUid,
      );
});

final userRatingAggregateProvider =
    StreamProvider.autoDispose.family<RatingAggregate, String>((ref, uid) {
  final me = ref.watch(authStateProvider.select((a) => a.value?.uid));
  if (me == null) return const Stream.empty();
  return ref.watch(ratingServiceProvider).streamAggregateForUser(uid);
});
