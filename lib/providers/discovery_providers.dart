import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../services/discovery_service.dart';
import '../services/swipe_service.dart';
import 'auth_providers.dart';
import 'profile_providers.dart';

final discoveryServiceProvider = Provider<DiscoveryService>((ref) {
  ref.keepAlive();
  return DiscoveryService(firestore: ref.watch(firestoreProvider));
});

final swipeServiceProvider = Provider<SwipeService>((ref) {
  ref.keepAlive();
  return SwipeService(firestore: ref.watch(firestoreProvider));
});

final candidatesProvider =
    FutureProvider.autoDispose<List<UserProfile>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Future.value(const []);
  return ref
      .watch(discoveryServiceProvider)
      .fetchCandidates(currentUid: user.uid);
});
