// lib/repositories/auth_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../repositories/profile_repository.dart';
import '../models/user_model.dart';
import '../models/profile_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ Login using roll number — looks up email from Firestore first
  Future<UserModel> loginWithRollNo({
    required String rollNo,
    required String password,
  }) async {
    // Step 1: Find the profile document where rollNo matches
    final query = await _db
        .collection('profiles')
        .where('rollNo', isEqualTo: rollNo)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception(
        'No account found with this roll number. Please sign up first.',
      );
    }

    // Step 2: Get the email from that profile
    final email = query.docs.first.data()['email'] as String;

    if (email.isEmpty) {
      throw Exception('Account email not found. Please contact support.');
    }

    // Step 3: Login with Firebase Auth using email + password
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user!;
    return UserModel(
      uid:   user.uid,
      email: user.email ?? '',
      name:  user.displayName ?? 'User',
    );
  }

  // ✅ Keep email login as fallback (used internally)
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
      uid:   user.uid,
      email: user.email ?? '',
      name:  user.displayName ?? 'User',
    );
  }

  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String rollNo,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user!;
    await user.updateDisplayName(name);

    final profileRepo = Get.find<ProfileRepository>();

    final profile = ProfileModel(
      id:        user.uid,
      name:      name,
      email:     email,
      phone:     phone,
      rollNo:    rollNo,
      avatarUrl: '',
    );

    await profileRepo.saveProfile(profile);

    return UserModel(
      uid:   user.uid,
      email: email,
      name:  name,
    );
  }

  // ✅ Password reset still uses email
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}