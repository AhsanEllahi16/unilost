// lib/modules/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../viewmodels/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _rollCtrl  = TextEditingController();

  late ProfileController c;

  @override
  void initState() {
    super.initState();
    c = Get.find<ProfileController>();

    // ✅ Prefill if profile already loaded
    _prefill();

    // ✅ Also prefill if profile loads AFTER screen opens
    ever(c.profile, (_) => _prefill());
  }

  void _prefill() {
    final p = c.profile.value;
    if (p == null) return;
    if (_nameCtrl.text.isEmpty)  _nameCtrl.text  = p.name;
    if (_phoneCtrl.text.isEmpty) _phoneCtrl.text = p.phone  ?? '';
    if (_rollCtrl.text.isEmpty)  _rollCtrl.text  = p.rollNo ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _rollCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await c.updateProfile(
      name:   _nameCtrl.text.trim(),
      phone:  _phoneCtrl.text.trim(),
      rollNo: _rollCtrl.text.trim(),
    );

    Get.back();
    Get.snackbar(
      'Saved',
      'Profile updated successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: UniLostTheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // AVATAR placeholder
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 44),
              ),
              const SizedBox(height: 24),

              // NAME
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 14),

              // ✅ PHONE — new field
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 14),

              // ✅ ROLL NO — new field
              TextFormField(
                controller: _rollCtrl,
                decoration: const InputDecoration(
                  labelText: 'Roll Number',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 28),

              // SAVE BUTTON
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: c.loading.value ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UniLostTheme.primary,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: c.loading.value
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}