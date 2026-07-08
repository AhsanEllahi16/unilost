// lib/main.dart
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'bindings/initial_binding.dart';
import 'theme.dart';
import 'theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load persisted theme BEFORE runApp
  await ThemeManager.init();

  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    // ignore: avoid_print
    print('PlatformDispatcher.onError: $error\n$stack');
    return true;
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // ignore: avoid_print
    print('Firebase initialized');
  } catch (e, s) {
    // ignore: avoid_print
    print('Firebase init failed: $e\n$s');
  }

  runApp(const UniLostApp());
}

class UniLostApp extends StatelessWidget {
  const UniLostApp({super.key});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 56, color: Colors.red),
                const SizedBox(height: 12),
                const Text(
                  'A build error occurred',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  details.exceptionAsString(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    };

    // ✅ ValueListenableBuilder rebuilds app when theme changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeMode,
      builder: (_, mode, __) {
        return GetMaterialApp(
          title: 'UniLost',
          debugShowCheckedModeBanner: false,

          initialBinding: InitialBinding(),
          getPages: AppPages.pages,
          initialRoute: Routes.splash,

          // ✅ Now uses persisted and reactive theme
          theme: UniLostTheme.light(),
          darkTheme: UniLostTheme.dark(),
          themeMode: mode,

          unknownRoute: GetPage(
            name: '/notfound',
            page: () => const Scaffold(
              body: Center(child: Text('Route not found')),
            ),
          ),

          builder: (context, child) {
            return GestureDetector(child: child);
          },
        );
      },
    );
  }
}