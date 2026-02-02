import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../viewmodels/posts_controller.dart';
import '../../models/post_model.dart';
import '../../widgets/item_card.dart';
import 'item_detail_screen.dart';
import 'post_item_screen.dart';

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
      ),
      body: user == null
          ? const Center(child: Text('Login required'))
          : Obx(() {
        final posts = postsC.myPosts(user.uid);
        if (posts.isEmpty) {
          return const Center(child: Text('No posts yet'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(14),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: posts.length,
          itemBuilder: (_, i) {
            final post = posts[i];
            return Stack(
              children: [
                ItemCard(
                  post: post,
                  onTap: () =>
                      Get.to(() => ItemDetailScreen(post: post)),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        Get.to(() =>
                            PostItemScreen(existingPost: post));
                      } else if (v == 'delete') {
                        await postsC.deletePost(post.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: UniLostTheme.primary,
        onPressed: () => Get.to(() => const PostItemScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
