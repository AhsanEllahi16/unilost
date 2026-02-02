// lib/modules/profile/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../viewmodels/theme_controller.dart';
import '../../viewmodels/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeC = Get.find<ThemeController>();
    final settingsC = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: UniLostTheme.primary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // -------- Appearance --------
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SwitchListTile(
              title: const Text('Dark mode'),
              subtitle: const Text('Toggle app appearance'),
              value: themeC.isDark,
              onChanged: (v) async {
                themeC.setDark(v);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                      Text('Dark mode is ${v ? 'ON' : 'OFF'}'),
                    ),
                  );
                });
              },
              secondary: const Icon(Icons.dark_mode),
            ),

            const Divider(height: 0),

            // -------- Notifications --------
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            // notificationsEnabled (RxBool)
            Obx(
                  () => SwitchListTile(
                title: const Text('Enable notifications'),
                subtitle: const Text(
                    'Receive match alerts and messages.'),
                value: settingsC.notificationsEnabled.value,
                onChanged: settingsC.setNotifications,
                secondary: const Icon(Icons.notifications_active),
              ),
            ),

            // autoMatchEnabled (RxBool)
            Obx(
                  () => SwitchListTile(
                title: const Text('Auto-match suggestions'),
                subtitle: const Text(
                    'Automatically suggest possible matches for your posts.'),
                value: settingsC.autoMatchEnabled.value,
                onChanged: settingsC.setAutoMatch,
                secondary: const Icon(Icons.auto_mode),
              ),
            ),

            const Divider(height: 0),

            // -------- Account --------
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'Account',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Privacy & safety'),
              subtitle: const Text('Control how your data is shared'),
              onTap: () => WidgetsBinding.instance.addPostFrameCallback(
                    (_) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy settings (demo)'),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shield),
              title: const Text('Blocked users'),
              subtitle: const Text('Manage blocked users'),
              onTap: () => WidgetsBinding.instance.addPostFrameCallback(
                    (_) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Blocked users (demo)'),
                  ),
                ),
              ),
            ),

            const Divider(height: 0),

            // -------- About --------
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'About',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App info'),
              subtitle: const Text('UniLost'),
              onTap: () => WidgetsBinding.instance.addPostFrameCallback(
                    (_) {
                  showAboutDialog(
                    context: context,
                    applicationName: 'UniLost - COMSATS Lost & Found',
                    applicationVersion: '1.0.0',
                    applicationIcon: Image.asset(
                      'assets/logo.jpeg',
                      width: 48,
                      height: 48,
                    ),
                    children: const [
                      Text('Demo app built for university project.'),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Reset demo settings button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: UniLostTheme.error,
                ),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Reset demo data'),
                      content: const Text(
                        'This will reset local demo settings. Continue?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(c).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(c).pop(true),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );

                  if (ok == true) {
                    if (themeC.isDark) {
                      themeC.setDark(false);
                    }
                    await settingsC.resetToDefaults();

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Demo settings reset'),
                        ),
                      );
                    });
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset demo settings'),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
