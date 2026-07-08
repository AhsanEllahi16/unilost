// lib/viewmodels/posts_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/posts_repository.dart';
import '../models/post_model.dart';
import '../services/matching_service.dart';
import '../utils/snackbars.dart';

class PostsController extends GetxController {
  final PostsRepository _repo;

  PostsController(this._repo);

  final posts        = <PostModel>[].obs;
  final loading      = false.obs;
  final Rx<MatchResult?> latestMatch = Rx<MatchResult?>(null);
  final matchLoading = false.obs;

  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _startStream();
  }

  void _startStream() {
    loading.value = true;
    _sub = _repo.streamPosts().listen(
          (list) {
        posts.assignAll(list);
        loading.value = false;
      },
      onError: (e) {
        loading.value = false;
        AppSnackbar.error('Failed to load posts. Please try again.');
      },
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<void> addPost(PostModel post) async {
    final String docId = await _repo.addPost(post);
    _runMatching(post, docId);
  }

  Future<void> _runMatching(PostModel post, String docId) async {
    try {
      matchLoading.value = true;

      final postData = {
        'title':         post.title,
        'description':   post.description,
        'location':      post.location,
        'category':      post.category,
        'image':         post.image,
        'postedByUid':   post.postedByUid,
        'postedByName':  post.postedByName,
        'postedByEmail': post.postedByEmail,
      };

      final result = await MatchingService.findMatches(
        postData,
        docId,
      );

      latestMatch.value = result;

      if (result != null && result.isMatch) {
        // ✅ Nice match found dialog instead of plain snackbar
        _showMatchDialog(result);
      }
    } catch (e) {
      // Silent fail
    } finally {
      matchLoading.value = false;
    }
  }

  // ✅ Beautiful match found dialog
  void _showMatchDialog(MatchResult result) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Celebration icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '🎉',
                    style: TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Match Found!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Confidence badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(result.confidence * 100).round()}% Confidence',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Matched item
              if (result.matchedPost != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.matchedPost!['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              result.matchedPost!['location'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              // Reason
              Text(
                result.reason,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Go to chat button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    Get.toNamed('/chats');
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Open Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Dismiss
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> updatePost({
    required String id,
    required String title,
    required String description,
    required String location,
    required String image,
  }) async {
    await _repo.updatePost(
      id:          id,
      title:       title,
      description: description,
      location:    location,
      image:       image,
    );
  }

  Future<void> deletePost(String id) async {
    await _repo.deletePost(id);
  }

  List<PostModel> myPosts(String uid) =>
      posts.where((p) => p.postedByUid == uid).toList();

  List<PostModel> lostPosts() =>
      posts.where((p) => p.category == 'lost').toList();

  List<PostModel> foundPosts() =>
      posts.where((p) => p.category == 'found').toList();
}