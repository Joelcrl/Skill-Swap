import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  const Rating({
    required this.id,
    required this.matchId,
    required this.raterUid,
    required this.ratedUid,
    required this.stars,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String matchId;
  final String raterUid;
  final String ratedUid;
  final int stars;
  final String note;
  final DateTime? createdAt;

  static String idFor({required String matchId, required String raterUid}) =>
      '${matchId}_$raterUid';

  factory Rating.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Rating(
      id: doc.id,
      matchId: (data['matchId'] as String?) ?? '',
      raterUid: (data['raterUid'] as String?) ?? '',
      ratedUid: (data['ratedUid'] as String?) ?? '',
      stars: (data['stars'] as num?)?.toInt() ?? 0,
      note: (data['note'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
