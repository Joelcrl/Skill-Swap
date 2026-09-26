import 'package:cloud_firestore/cloud_firestore.dart';

enum SwipeDirection { like, pass }

class Swipe {
  const Swipe({
    required this.swiperUid,
    required this.swipedUid,
    required this.direction,
    required this.createdAt,
    this.roundNumber = 1,
  });

  final String swiperUid;
  final String swipedUid;
  final SwipeDirection direction;
  final DateTime? createdAt;
  final int roundNumber;

  static String idFor(String swiperUid, String swipedUid, {int round = 1}) {
    final base = '${swiperUid}_$swipedUid';
    return round <= 1 ? base : '${base}_r$round';
  }

  factory Swipe.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Swipe(
      swiperUid: (data['swiperUid'] as String?) ?? '',
      swipedUid: (data['swipedUid'] as String?) ?? '',
      direction: (data['direction'] as String?) == 'like'
          ? SwipeDirection.like
          : SwipeDirection.pass,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      roundNumber: (data['roundNumber'] as int?) ?? 1,
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'swiperUid': swiperUid,
        'swipedUid': swipedUid,
        'direction': direction == SwipeDirection.like ? 'like' : 'pass',
        'createdAt': FieldValue.serverTimestamp(),
        'roundNumber': roundNumber,
      };
}
