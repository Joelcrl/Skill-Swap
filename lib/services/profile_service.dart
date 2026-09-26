import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

class ProfileService {
  ProfileService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<UserProfile?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  Future<void> createProfile({
    required String uid,
    required String email,
    required String alias,
    List<String> skillsOffered = const [],
    List<String> skillsWanted = const [],
    List<String> interests = const [],
  }) async {
    final profile = UserProfile(
      uid: uid,
      alias: alias,
      email: email,
      pfpUrl: '',
      bio: '',
      skillsOffered: skillsOffered,
      skillsWanted: skillsWanted,
      interests: interests,
      rating: 0.0,
      ratingCount: 0,
      trustBadges: const [],
      activeMatchId: null,
      createdAt: null,
    );
    await _users.doc(uid).set(profile.toCreateMap());
  }

  Future<void> updateProfile({
    required String uid,
    String? alias,
    List<String>? skillsOffered,
    List<String>? skillsWanted,
    List<String>? interests,
  }) {
    final updates = <String, dynamic>{};
    if (alias != null) updates['alias'] = alias;
    if (skillsOffered != null) updates['skillsOffered'] = skillsOffered;
    if (skillsWanted != null) updates['skillsWanted'] = skillsWanted;
    if (interests != null) updates['interests'] = interests;
    if (updates.isEmpty) return Future.value();
    return _users.doc(uid).update(updates);
  }
}
