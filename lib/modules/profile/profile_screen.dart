import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController c = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: UniLostTheme.primary,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAllNamed(Routes.home);
          },
        ),
      ),

      body: Obx(() {
        if (c.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (c.profile.value == null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Not logged in"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.offAllNamed(Routes.auth),
                child: const Text("Go Login"),
              )
            ],
          );
        }

        final p = c.profile.value!;

        return Column(
          children: [
            const SizedBox(height: 40),

            const CircleAvatar(
              radius: 45,
              child: Icon(Icons.person, size: 48),
            ),
            const SizedBox(height: 12),

            Text(
              p.name,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(p.email),
            Text("Roll: ${p.rollNo ?? ''}"),

            const SizedBox(height: 30),

            _button("Edit Profile", Routes.editProfile),
            _button("My Posts", Routes.myPosts),
            _button("Settings", Routes.settings),

            const SizedBox(height: 24),

            OutlinedButton(
              onPressed: () async {
                await c.logout();
                Get.offAllNamed(Routes.auth);
              },
              child: const Text("Logout"),
            )
          ],
        );
      }),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,   // profile tab
        onTap: (i) {
          if (i == 0) Get.offAllNamed(Routes.home);
          if (i == 1) Get.offAllNamed(Routes.lost);
          if (i == 2) Get.offAllNamed(Routes.found);
        },
        selectedItemColor: UniLostTheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: "Lost"),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle), label: "Found"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _button(String title, String routeName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          backgroundColor: UniLostTheme.primary,
        ),
        onPressed: () => Get.toNamed(routeName),
        child: Text(title, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
