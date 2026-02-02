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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/logo.jpeg',
                  height: 80,
                ),
              ),
              const SizedBox(height: 20),

              // NAME - no Obx needed, we only write to Rx
              TextFormField(
                onChanged: (v) => c.name.value = v,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),

              // EMAIL - no Obx needed, we only write to Rx
              TextFormField(
                onChanged: (v) => c.email.value = v,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // PASSWORD - Obx is correct here (reads c.obscure.value)
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

              const SizedBox(height: 20),

              // SIGNUP BUTTON - Obx is correct (reads c.loading.value)
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
