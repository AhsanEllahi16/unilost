import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/profile_repository.dart';
import '../models/profile_model.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repo;

  ProfileController(this._repo);

  final profile = Rx<ProfileModel?>(null);
  final loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      profile.value = null;
      return;
    }

    loading.value = true;

    profile.value = await _repo.fetchProfile(user.uid);

    loading.value = false;
  }

  Future<void> updateName(String name) async {
    final p = profile.value;
    if (p == null) return;

    loading.value = true;

    final updated = p.copyWith(name: name);

    await _repo.saveProfile(updated);
    profile.value = updated;

    loading.value = false;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    profile.value = null;
  }
}
