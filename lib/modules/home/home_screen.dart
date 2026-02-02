import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../widgets/item_card.dart';
import '../../viewmodels/posts_controller.dart';
import '../../routes/app_routes.dart';
import '../../models/post_model.dart';
import '../posts/item_detail_screen.dart';
import '../posts/post_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final PostsController postsC = Get.find<PostsController>();

  void _onNavTap(int index) {
    if (_currentIndex == index) return;

    setState(() => _currentIndex = index);

    if (index == 1) Get.toNamed(Routes.lost);
    if (index == 2) Get.toNamed(Routes.found);
    if (index == 3) Get.toNamed(Routes.profile);
  }

  void _openDetail(PostModel post) {
    Get.to(() => ItemDetailScreen(post: post));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "UniLost - Home",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: UniLostTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Get.toNamed(Routes.search),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Get.toNamed(Routes.chatsList),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Get.toNamed(Routes.notifications),
          ),
        ],
      ),

      body: Obx(() {
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
              onTap: () => _openDetail(post),
            );
          },
        );
      }),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: UniLostTheme.primary,
        onPressed: () => Get.to(() => const PostItemScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Post Item'),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: UniLostTheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavTap,
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
      ),
    );
  }
}
