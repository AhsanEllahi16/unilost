// lib/modules/startup/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../widgets/primary_button.dart';
import '../../routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: UniLostTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            children: [
              // Top: logo + app name
              Row(
                children: [
                  Image.asset('assets/logo.jpeg', height: 44),
                  const SizedBox(width: 12),
                  Text(
                    'UniLost',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: UniLostTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Hero / illustration card
              Expanded(
                child: Center(
                  child: Container(
                    width: mq.width * (mq.width > 600 ? 0.6 : 0.88),
                    padding: const EdgeInsets.symmetric(
                      vertical: 26,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          UniLostTheme.primaryLight,
                          UniLostTheme.accent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 14,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search,
                          size: mq.width > 600 ? 96 : 72,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Find lost items — fast',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Report lost and found items at COMSATS. Get notified when matches are found and contact the finder directly.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bottom CTAs
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                    text: 'Login',
                    onPressed: () => Get.toNamed(Routes.auth),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: 'Create account',
                    filled: false,
                    onPressed: () => Get.toNamed(Routes.signup),
                  ),
                  const SizedBox(height: 12),

                  // ✅ Continue as guest (restored)
                  TextButton(
                    onPressed: () => Get.offAllNamed(Routes.home),
                    child: const Text('Continue as guest'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
