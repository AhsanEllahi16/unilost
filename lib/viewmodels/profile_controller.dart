// lib/viewmodels/profile_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/profile_repository.dart';
import '../models/profile_model.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repo;

  ProfileController(this._repo);

  final profile      = Rx<ProfileModel?>(null);
  final loading      = false.obs;

  // ✅ Real stats from Firestore
  final matchCount   = 0.obs;
  final alertCount   = 0.obs;

  StreamSubscription? _profileSub;
  StreamSubscription? _notifSub;

  @override
  void onInit() {
    super.onInit();
    // ✅ Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        loadProfile();
        _startMatchCountStream(user.uid);
        _startAlertCountStream(user.uid);
      } else {
        profile.value = null;
        matchCount.value = 0;
        alertCount.value = 0;
        _profileSub?.cancel();
        _notifSub?.cancel();
        loading.value = false;
      }
    });
  }

  // ✅ Stream match count from profile document
  void _startMatchCountStream(String uid) {
    _profileSub?.cancel();
    _profileSub = FirebaseFirestore.instance
        .collection('profiles')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data() ?? {};
        matchCount.value = (data['matchCount'] as int?) ?? 0;
      }
    });
  }

  // ✅ Stream unread notifications count
  void _startAlertCountStream(String uid) {
    _notifSub?.cancel();
    _notifSub = FirebaseFirestore.instance
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snap) {
      alertCount.value = snap.docs.length;
    });
  }

  @override
  void onClose() {
    _profileSub?.cancel();
    _notifSub?.cancel();
    super.onClose();
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      profile.value = null;
      return;
    }

    loading.value = true;

    var p = await _repo.fetchProfile(user.uid);

    // ✅ Auto create profile if doesn't exist
    if (p == null) {
      p = ProfileModel(
        id:        user.uid,
        name:      user.displayName ?? 'User',
        email:     user.email ?? '',
        phone:     '',
        rollNo:    '',
        avatarUrl: '',
      );
      await _repo.saveProfile(p);
    }

    profile.value = p;
    loading.value = false;
  }

  Future<void> updateName(String name) async {
    await updateProfile(name: name);
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
    String? rollNo,
  }) async {
    final p = profile.value;
    if (p == null) return;

    loading.value = true;

    final updated = p.copyWith(
      name:   name,
      phone:  phone,
      rollNo: rollNo,
    );

    await _repo.saveProfile(updated);
    profile.value = updated;
    loading.value = false;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    profile.value   = null;
    matchCount.value = 0;
    alertCount.value = 0;
  }
}