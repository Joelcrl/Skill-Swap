import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  ref.keepAlive();
  return FirebaseAuth.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  ref.keepAlive();
  return AuthService(ref.watch(firebaseAuthProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  ref.keepAlive();
  return ref.watch(authServiceProvider).authStateChanges();
});
