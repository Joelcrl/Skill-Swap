import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/match.dart';
import '../models/user_profile.dart';
import '../services/match_service.dart';
import 'auth_providers.dart';
import 'profile_providers.dart';

final matchServiceProvider = Provider<MatchService>((ref) {
  ref.keepAlive();
  return MatchService(firestore: ref.watch(firestoreProvider));
});

final myMatchesStreamProvider = StreamProvider<List<Match>>((ref) {
  ref.keepAlive();
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(matchServiceProvider).streamMyMatches(myUid: user.uid);
});

// See chat_providers.dart: autoDispose + re-subscribe when the uid changes.
final matchByIdProvider =
    StreamProvider.autoDispose.family<Match?, String>((ref, matchId) {
  final uid = ref.watch(authStateProvider.select((a) => a.value?.uid));
  if (uid == null) return const Stream.empty();
  return ref.watch(matchServiceProvider).streamMatch(matchId: matchId);
});

final userByIdProvider =
    StreamProvider.autoDispose.family<UserProfile?, String>((ref, uid) {
  final me = ref.watch(authStateProvider.select((a) => a.value?.uid));
  if (me == null) return const Stream.empty();
  return ref.watch(profileServiceProvider).watchProfile(uid);
});
