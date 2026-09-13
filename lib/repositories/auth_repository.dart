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

  // ── Check roll number against the university's valid_students list ──
  Future<Map<String, dynamic>> validateRollNumber(String rollNo) async {
    final doc = await _db.collection('valid_students').doc(rollNo).get();

    if (!doc.exists) {
      throw Exception(
        'This roll number is not recognized as a valid COMSATS Sahiwal '
            'student. Please contact administration if you believe this is '
            'an error.',
      );
    }

    final data = doc.data()!;
    final bool alreadyRegistered = data['isRegistered'] == true;

    if (alreadyRegistered) {
      throw Exception(
        'An account already exists for this roll number. Please login '
            'instead.',
      );
    }

    return data;
  }

  // ✅ Login using roll number — now looks up email via the public
  // roll_lookup collection instead of querying profiles, since that
  // lookup must work BEFORE the user is authenticated.
  Future<UserModel> loginWithRollNo({
    required String rollNo,
    required String password,
  }) async {
    final doc = await _db.collection('roll_lookup').doc(rollNo).get();

    if (!doc.exists) {
      throw Exception(
        'No account found with this roll number. Please sign up first.',
      );
    }

    final email = doc.data()?['email'] as String? ?? '';

    if (email.isEmpty) {
      throw Exception('Account email not found. Please contact support.');
    }

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
    // ── Step 1: Validate roll number BEFORE creating any account ──
    await validateRollNumber(rollNo);

    // ── Step 2: Create the Firebase Auth account ──
    // This automatically signs the new user in, so everything after
    // this point runs as an authenticated request.
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

    // ── Step 3: Mark this roll number as registered ──
    await _db.collection('valid_students').doc(rollNo).update({
      'isRegistered': true,
    });

    // ── Step 4: Create the public roll_lookup entry for future logins ──
    await _db.collection('roll_lookup').doc(rollNo).set({
      'email': email,
      'uid':   user.uid,
    });

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