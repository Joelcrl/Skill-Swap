import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../services/profile_service.dart';
import 'auth_providers.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  ref.keepAlive();
  return FirebaseFirestore.instance;
});

final profileServiceProvider = Provider<ProfileService>((ref) {
  ref.keepAlive();
  return ProfileService(firestore: ref.watch(firestoreProvider));
});

final currentProfileProvider = StreamProvider<UserProfile?>((ref) {
  ref.keepAlive();
  final auth = ref.watch(authStateProvider);
  final user = auth.value;
  if (user == null) return Stream.value(null);
  return ref.watch(profileServiceProvider).watchProfile(user.uid);
});
