import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message.dart';
import '../services/chat_service.dart';
import 'auth_providers.dart';
import 'profile_providers.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  ref.keepAlive();
  return ChatService(firestore: ref.watch(firestoreProvider));
});

// autoDispose closes the Firestore listener when no screen uses it, and
// watching the signed-in uid re-opens it after sign-out / sign-in (a listener
// opened in one session dies with permission-denied when the user signs out).
final messagesStreamProvider =
    StreamProvider.autoDispose.family<List<Message>, String>((ref, matchId) {
  final uid = ref.watch(authStateProvider.select((a) => a.value?.uid));
  if (uid == null) return const Stream.empty();
  return ref.watch(chatServiceProvider).streamMessages(matchId: matchId);
});

final lastMessageProvider =
    StreamProvider.autoDispose.family<Message?, String>((ref, matchId) {
  final uid = ref.watch(authStateProvider.select((a) => a.value?.uid));
  if (uid == null) return const Stream.empty();
  return ref.watch(chatServiceProvider).streamLastMessage(matchId: matchId);
});
