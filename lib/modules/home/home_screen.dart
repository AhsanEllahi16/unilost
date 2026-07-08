// lib/modules/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../widgets/item_card.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/main_bottom_nav.dart';
import '../../viewmodels/posts_controller.dart';
import '../../routes/app_routes.dart';
import '../../models/post_model.dart';
import '../posts/item_detail_screen.dart';
import '../posts/post_item_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PostsController postsC = Get.find<PostsController>();

    return Scaffold(
      // ✅ Shared AppBar with search, chat, notification icons
      appBar: const MainAppBar(title: 'UniLost - Home'),

      body: Obx(() {
        if (postsC.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = postsC.posts;

        if (posts.isEmpty) {
          return const Center(
            child: Text(
              'No posts yet.\nTap Post Item to create one.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: posts.length,
          itemBuilder: (_, i) {
            final post = posts[i];
            return ItemCard(
              post: post,
              onTap: () => Get.to(() => ItemDetailScreen(post: post)),
            );
          },
        );
      }),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: UniLostTheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => Get.to(() => const PostItemScreen()),
        icon: const Icon(Icons.add),
        label: const Text(
          'Post Item',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // ✅ Shared bottom nav
      bottomNavigationBar: const MainBottomNav(currentIndex: 0),
    );
  }
}