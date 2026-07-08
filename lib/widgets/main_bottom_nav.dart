// lib/widgets/main_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme.dart';
import '../routes/app_routes.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;

  const MainBottomNav({super.key, required this.currentIndex});

  void _onTap(int index) {
    if (index == currentIndex) return;
    if (index == 0) Get.offAllNamed(Routes.home);
    if (index == 1) Get.offAllNamed(Routes.lost);
    if (index == 2) Get.offAllNamed(Routes.found);
    if (index == 3) Get.offAllNamed(Routes.profile);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: UniLostTheme.primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: _onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Lost',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle),
          label: 'Found',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}