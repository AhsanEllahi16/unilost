// lib/modules/posts/lost_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../widgets/item_card.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/main_bottom_nav.dart';
import '../../viewmodels/posts_controller.dart';
import '../../models/post_model.dart';
import '../posts/item_detail_screen.dart';
import '../posts/post_item_screen.dart';

class LostListScreen extends StatelessWidget {
  const LostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PostsController postsC = Get.find<PostsController>();

    return Scaffold(
      // ✅ Shared AppBar with search, chat, notification icons
      appBar: const MainAppBar(title: 'Lost Items'),

      body: Obx(() {
        final posts = postsC.lostPosts();

        if (posts.isEmpty) {
          return const Center(
            child: Text(
              'No lost items yet.',
              style: TextStyle(fontSize: 15),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(14),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
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

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: UniLostTheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => Get.to(() => const PostItemScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Report Lost'),
      ),

      // ✅ Shared bottom nav
      bottomNavigationBar: const MainBottomNav(currentIndex: 1),
    );
  }
}