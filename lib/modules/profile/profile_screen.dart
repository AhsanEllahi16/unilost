// lib/modules/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/profile_controller.dart';
import '../../viewmodels/posts_controller.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/main_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController c      = Get.find<ProfileController>();
  final PostsController   postsC = Get.find<PostsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: 'Profile'),

      body: Obx(() {
        if (c.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (c.profile.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_off_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Not logged in',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(Routes.auth),
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          );
        }

        final p            = c.profile.value!;
        final myUid        = FirebaseAuth.instance.currentUser?.uid ?? '';
        final myPostsCount = postsC.myPosts(myUid).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // ── AVATAR + NAME ROW ──
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: UniLostTheme.primary,
                    backgroundImage: p.avatarUrl != null &&
                        p.avatarUrl!.isNotEmpty
                        ? NetworkImage(p.avatarUrl!)
                        : null,
                    child: p.avatarUrl == null || p.avatarUrl!.isEmpty
                        ? ClipOval(
                      child: Image.asset(
                        'assets/logo.jpeg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Roll: ${p.rollNo ?? ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── STATS ROW — real numbers from Firestore ──
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    // ✅ Real posts count
                    _statItem(
                      context,
                      value: myPostsCount.toString(),
                      label: 'Posts',
                    ),
                    _divider(),
                    // ✅ Real match count from Firestore
                    Obx(() => _statItem(
                      context,
                      value: c.matchCount.value.toString(),
                      label: 'Matches',
                    )),
                    _divider(),
                    // ✅ Real alerts count from Firestore
                    Obx(() => _statItem(
                      context,
                      value: c.alertCount.value.toString(),
                      label: 'Alerts',
                      highlight: c.alertCount.value > 0,
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── CONTACT INFO CARD ──
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _infoTile(
                      context,
                      icon: Icons.phone_outlined,
                      value: p.phone != null && p.phone!.isNotEmpty
                          ? p.phone!
                          : 'No phone added',
                      label: 'Phone',
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.1),
                    ),
                    _infoTile(
                      context,
                      icon: Icons.email_outlined,
                      value: p.email,
                      label: 'Email',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── EDIT PROFILE ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.editProfile),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UniLostTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── MY POSTS ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.myPosts),
                  icon: const Icon(Icons.list_alt_outlined),
                  label: const Text(
                    'My Posts',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UniLostTheme.primaryLight,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── LOGOUT ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await c.logout();
                    Get.offAllNamed(Routes.auth);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: UniLostTheme.primary,
                    side: const BorderSide(
                      color: UniLostTheme.primary,
                    ),
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── SETTINGS & HELP ──
              TextButton(
                onPressed: () => Get.toNamed(Routes.settings),
                child: const Text(
                  'Settings & Help',
                  style: TextStyle(
                    color: UniLostTheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      }),

      bottomNavigationBar: const MainBottomNav(currentIndex: 3),
    );
  }

  // ── HELPERS ──

  Widget _statItem(
      BuildContext context, {
        required String value,
        required String label,
        bool highlight = false,
      }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              // ✅ Alerts turn red when there are unread ones
              color: highlight
                  ? Colors.red
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _infoTile(
      BuildContext context, {
        required IconData icon,
        required String value,
        required String label,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.6),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}