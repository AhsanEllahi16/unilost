// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'bindings/initial_binding.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Make uncaught Flutter errors visible on screen and printed
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    if (kDebugMode) {
      // Keep default red error screen in debug mode
    }
  };

  // Catch async errors (useful on web)
  PlatformDispatcher.instance.onError = (error, stack) {
    // ignore: avoid_print
    print('PlatformDispatcher.onError: $error\n$stack');
    return true; // we handled it
  };

  // Try to initialize Firebase but don't crash the whole app if it fails.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // ignore: avoid_print
    print('Firebase initialized');
  } catch (e, s) {
    // ignore: avoid_print
    print('Firebase init failed: $e\n$s');
    // Continue in demo mode
  }

  runApp(const UniLostApp());
}

class UniLostApp extends StatelessWidget {
  const UniLostApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Custom ErrorWidget: visible red error box when a build throws
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

    return GetMaterialApp(
      title: 'UniLost',
      debugShowCheckedModeBanner: false,

      // 🔹 All controllers are created here (ThemeController, SettingsController, PostsController, ChatController)
      initialBinding: InitialBinding(),

      // 🔹 Central routes
      getPages: AppPages.pages,
      initialRoute: Routes.splash, // you can change to Routes.welcome or Routes.auth later if needed

      // 🔹 App theme
      theme: UniLostTheme.light(),
      darkTheme: UniLostTheme.dark(),
      themeMode: ThemeMode.system,

      // Fallback route
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const Scaffold(
          body: Center(child: Text('Route not found')),
        ),
      ),

      // You can wrap here with other widgets if needed later (e.g., ScreenUtil, Toast overlay, etc.)
      builder: (context, child) {
        return GestureDetector(
          child: child,
        );
      },
    );
  }
}
