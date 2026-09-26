import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  const Message({
    required this.id,
    required this.senderUid,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String senderUid;
  final String text;
  final DateTime? createdAt;

  factory Message.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Message(
      id: doc.id,
      senderUid: (data['senderUid'] as String?) ?? '',
      text: (data['text'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
