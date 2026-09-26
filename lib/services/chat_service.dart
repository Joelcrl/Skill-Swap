import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message.dart';

class ChatService {
  ChatService({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _messages(String matchId) =>
      _firestore.collection('matches').doc(matchId).collection('messages');

  Stream<List<Message>> streamMessages({required String matchId}) {
    return _messages(matchId)
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) => snap.docs.map(Message.fromFirestore).toList());
  }

  Stream<Message?> streamLastMessage({required String matchId}) {
    return _messages(matchId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty
            ? null
            : Message.fromFirestore(snap.docs.first));
  }

  Future<void> sendMessage({
    required String matchId,
    required String senderUid,
    required String text,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return Future.value();
    return _messages(matchId).add({
      'senderUid': senderUid,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
