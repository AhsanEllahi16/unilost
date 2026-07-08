// lib/modules/auth/login/login_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme.dart';
import '../../../routes/app_routes.dart';
import 'login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LoginControllerX>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: UniLostTheme.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // LOGO
                Center(
                  child: Image.asset(
                    'assets/logo.jpeg',
                    height: 88,
                  ),
                ),
                const SizedBox(height: 8),

                // TITLE
                const Center(
                  child: Text(
                    'Welcome to UniLost',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Login with your roll number',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ✅ ROLL NUMBER field
                TextField(
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Roll Number',
                    hintText: 'e.g. FA21-BCE-001',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  onChanged: (v) => c.rollNo.value = v,
                ),
                const SizedBox(height: 14),

                // PASSWORD with eye toggle
                Obx(() => TextField(
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
                      onPressed: c.toggleObscure,
                    ),
                  ),
                  onChanged: (v) => c.password.value = v,
                )),
                const SizedBox(height: 20),

                // LOGIN BUTTON
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: c.loading.value ? null : c.login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UniLostTheme.primary,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: c.loading.value
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      'Login',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )),
                const SizedBox(height: 14),

                // SIGNUP LINK
                TextButton(
                  onPressed: () => Get.toNamed(Routes.signup),
                  child: const Text("Don't have an account? Sign up"),
                ),

                // FORGOT PASSWORD LINK
                TextButton(
                  onPressed: () => Get.toNamed(Routes.forgot),
                  child: const Text('Forgot password? Reset via email'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}