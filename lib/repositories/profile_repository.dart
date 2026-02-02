import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_model.dart';

class ProfileRepository {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Load profile
  Future<ProfileModel?> fetchProfile(String uid) async {
    final doc = await _db.collection("profiles").doc(uid).get();

    if (!doc.exists) return null;

    return ProfileModel.fromFirestore(doc);
  }

  // Save / update
  Future<void> saveProfile(ProfileModel profile) async {
    await _db
        .collection("profiles")
        .doc(profile.id)
        .set(profile.toFirestore(),
        SetOptions(merge: true));
  }

  // Logout invalidates only Firebase Auth user
  Future<void> logout() async {
    // nothing stored in firestore locally
    await Future.value();
  }
}
