import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme.dart';
import '../../../widgets/primary_button.dart';
import '../../../routes/app_routes.dart';
import 'forgot_controller.dart';

class ForgotView extends StatelessWidget {
  const ForgotView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ForgotControllerX>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset password'),
        backgroundColor: UniLostTheme.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            children: [
              Image.asset('assets/logo.jpeg', height: 84),
              const SizedBox(height: 12),

              const Text(
                'Enter your account email and we will send a link to reset your password.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 18),

              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                onChanged: (v) => c.email.value = v,
              ),

              const SizedBox(height: 20),

              Obx(
                    () => c.sending.value
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Send reset email',
                    onPressed: c.sendReset,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Get.offAllNamed(Routes.auth),
                child: const Text('Back to login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
