// lib/utils/snackbars.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme.dart';

class AppSnackbar {
  // ✅ SUCCESS — green
  static void success(String message) {
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
      messageText: const SizedBox.shrink(),
      backgroundColor: const Color(0xFF2E7D32),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // ✅ ERROR — red
  static void error(String message) {
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      messageText: const SizedBox.shrink(),
      backgroundColor: const Color(0xFFC62828),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // ✅ INFO — blue
  static void info(String message) {
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      messageText: const SizedBox.shrink(),
      backgroundColor: UniLostTheme.primary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // ✅ WARNING — orange
  static void warning(String message) {
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      messageText: const SizedBox.shrink(),
      backgroundColor: const Color(0xFFE65100),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // ✅ Convert ugly Firebase errors to friendly messages
  static String friendlyFirebaseError(dynamic error) {
    final msg = error.toString().toLowerCase();

    if (msg.contains('wrong-password') ||
        msg.contains('invalid-credential') ||
        msg.contains('invalid credential')) {
      return 'Incorrect password. Please try again.';
    }
    if (msg.contains('user-not-found')) {
      return 'No account found with this roll number.';
    }
    if (msg.contains('email-already-in-use')) {
      return 'This email is already registered. Please login.';
    }
    if (msg.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (msg.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    if (msg.contains('network-request-failed') ||
        msg.contains('network')) {
      return 'No internet connection. Please check your network.';
    }
    if (msg.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a few minutes and try again.';
    }
    if (msg.contains('user-disabled')) {
      return 'This account has been disabled. Contact support.';
    }
    if (msg.contains('permission-denied')) {
      return 'Access denied. Please login again.';
    }
    if (msg.contains('no account found')) {
      return 'No account found with this roll number. Please sign up first.';
    }

    // Default fallback
    return 'Something went wrong. Please try again.';
  }
}