import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../repositories/profile_repository.dart';
import '../models/user_model.dart';
import '../models/profile_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get profile repo
  final ProfileRepository profileRepo = Get.find<ProfileRepository>();

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user!;
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? 'User',
    );
  }

  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user!;
    await user.updateDisplayName(name);

    // create firestore profile
    final profile = ProfileModel(
      id: user.uid,
      name: name,
      email: email,
      phone: "",
      rollNo: "",
      avatarUrl: "",
    );

    await profileRepo.saveProfile(profile);

    return UserModel(
      uid: user.uid,
      email: email,
      name: name,
    );
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
