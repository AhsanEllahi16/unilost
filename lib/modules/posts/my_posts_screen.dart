// lib/modules/posts/my_posts_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../viewmodels/posts_controller.dart';
import '../../models/post_model.dart';
import '../../widgets/item_card.dart';
import '../posts/item_detail_screen.dart';
import '../posts/post_item_screen.dart';

class MyPostsScreen extends StatelessWidget {
  MyPostsScreen({super.key});

  final PostsController postsC = Get.find<PostsController>();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
        backgroundColor: UniLostTheme.primary,
        // ✅ Always show back arrow
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: user == null
          ? const Center(child: Text('Login required'))
          : Obx(() {
        final posts = postsC.myPosts(user.uid);
        if (posts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.post_add_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap + to create your first post',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(14),
          separatorBuilder: (_, __) =>
          const SizedBox(height: 8),
          itemCount: posts.length,
          itemBuilder: (_, i) {
            final post = posts[i];
            return Stack(
              children: [
                ItemCard(
                  post: post,
                  onTap: () => Get.to(
                        () => ItemDetailScreen(post: post),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        await Get.to(
                              () => PostItemScreen(
                            existingPost: post,
                          ),
                        );
                      } else if (v == 'delete') {
                        await postsC.deletePost(post.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 18,
                                color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
                              style:
                              TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }),

      // ✅ FAB icon white
      floatingActionButton: FloatingActionButton(
        backgroundColor: UniLostTheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => Get.to(() => const PostItemScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}