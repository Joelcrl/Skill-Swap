import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.alias,
    required this.email,
    required this.pfpUrl,
    required this.bio,
    required this.skillsOffered,
    required this.skillsWanted,
    required this.interests,
    required this.rating,
    required this.ratingCount,
    required this.trustBadges,
    required this.activeMatchId,
    required this.createdAt,
  });

  final String uid;
  final String alias;
  final String email;
  final String pfpUrl;
  final String bio;
  final List<String> skillsOffered;
  final List<String> skillsWanted;
  final List<String> interests;
  final double rating;
  final int ratingCount;
  final List<String> trustBadges;
  final String? activeMatchId;
  final DateTime? createdAt;

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return UserProfile(
      uid: doc.id,
      alias: (data['alias'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      pfpUrl: (data['pfpUrl'] as String?) ?? '',
      bio: (data['bio'] as String?) ?? '',
      skillsOffered:
          (data['skillsOffered'] as List?)?.cast<String>() ?? const [],
      skillsWanted:
          (data['skillsWanted'] as List?)?.cast<String>() ?? const [],
      interests: (data['interests'] as List?)?.cast<String>() ?? const [],
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (data['ratingCount'] as int?) ?? 0,
      trustBadges:
          (data['trustBadges'] as List?)?.cast<String>() ?? const [],
      activeMatchId: data['activeMatchId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'alias': alias,
        'email': email,
        'pfpUrl': pfpUrl,
        'bio': bio,
        'skillsOffered': skillsOffered,
        'skillsWanted': skillsWanted,
        'interests': interests,
        'rating': rating,
        'ratingCount': ratingCount,
        'trustBadges': trustBadges,
        'activeMatchId': activeMatchId,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
