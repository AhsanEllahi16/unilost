// lib/modules/auth/signup/signup_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/primary_button.dart';
import '../../../theme.dart';
import '../../../routes/app_routes.dart';
import 'signup_controller.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SignupControllerX>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: UniLostTheme.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // LOGO
              Center(
                child: Image.asset(
                  'assets/logo.jpeg',
                  height: 80,
                ),
              ),
              const SizedBox(height: 20),

              // FULL NAME
              TextFormField(
                onChanged: (v) => c.name.value = v,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),

              // EMAIL
              TextFormField(
                onChanged: (v) => c.email.value = v,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // ✅ PHONE — new field
              TextFormField(
                onChanged: (v) => c.phone.value = v,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: 'e.g. +92 300 0000000',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              // ✅ ROLL NUMBER — new field
              TextFormField(
                onChanged: (v) => c.rollNo.value = v,
                decoration: const InputDecoration(
                  labelText: 'Roll Number',
                  prefixIcon: Icon(Icons.badge_outlined),
                  hintText: 'e.g. FA21-BCE-001',
                ),
              ),
              const SizedBox(height: 12),

              // PASSWORD
              Obx(
                    () => TextFormField(
                  onChanged: (v) => c.password.value = v,
                  obscureText: c.obscure.value,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        c.obscure.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: c.togglePassword,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // SIGNUP BUTTON
              Obx(
                    () => c.loading.value
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Sign Up',
                    onPressed: c.signup,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // LOGIN LINK
              TextButton(
                onPressed: () => Get.offAllNamed(Routes.auth),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}