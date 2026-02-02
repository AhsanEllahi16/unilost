import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme.dart';
import '../../../routes/app_routes.dart';
import 'login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller created by binding
    final c = Get.find<LoginControllerX>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: UniLostTheme.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: SingleChildScrollView(
            // helps avoid bottom overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/logo.jpeg',
                    height: 88,
                  ),
                ),
                const SizedBox(height: 12),

                // Email (no Obx – we are just writing to Rx value)
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  onChanged: (v) => c.email.value = v,
                ),

                const SizedBox(height: 12),

                // Password (no Obx – we are just writing to Rx value)
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  onChanged: (v) => c.password.value = v,
                ),

                const SizedBox(height: 12),

                // Only this needs Obx because it READS loading.value
                Obx(
                      () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: c.loading.value ? null : c.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UniLostTheme.primary,
                      ),
                      child: c.loading.value
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Login'),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => Get.toNamed(Routes.signup),
                  child: const Text("Don't have an account? Sign up"),
                ),

                TextButton(
                  onPressed: () => Get.toNamed(Routes.forgot),
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
