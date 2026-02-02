import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../widgets/item_card.dart';
import '../../viewmodels/posts_controller.dart';
import '../../routes/app_routes.dart';
import '../../models/post_model.dart';
import '../posts/item_detail_screen.dart';
import '../posts/post_item_screen.dart';

class LostListScreen extends StatefulWidget {
  const LostListScreen({super.key});

  @override
  State<LostListScreen> createState() => _LostListScreenState();
}

class _LostListScreenState extends State<LostListScreen> {
  final PostsController postsC = Get.find<PostsController>();

  int _currentIndex = 1;

  void _openDetail(PostModel post) {
    Get.to(() => ItemDetailScreen(post: post));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost Items'),
        backgroundColor: UniLostTheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed(Routes.home),
        ),
      ),

      body: Obx(() {
        final posts = postsC.lostPosts();

        if (posts.isEmpty) {
          return const Center(child: Text('No lost items'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(14),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: posts.length,
          itemBuilder: (_, i) {
            final post = posts[i];
            return ItemCard(
              post: post,
              onTap: () => _openDetail(post),
            );
          },
        );
      }),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: UniLostTheme.primary,
        onPressed: () => Get.to(() => const PostItemScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Report Lost'),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: UniLostTheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) Get.offAllNamed(Routes.home);
          if (index == 2) Get.offAllNamed(Routes.found);
          if (index == 3) Get.offAllNamed(Routes.profile);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Lost'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Found'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
