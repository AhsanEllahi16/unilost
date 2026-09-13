// lib/viewmodels/posts_controller.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/posts_repository.dart';
import '../models/post_model.dart';
import '../services/matching_service.dart';
import '../utils/snackbars.dart';

class PostsController extends GetxController {
  final PostsRepository _repo;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  Future<void> addPost(
      PostModel post, {
        List<Map<String, String>>? verificationQAPairs,
      }) async {
    final String docId = await _repo.addPost(post);

    if (post.category == 'found' &&
        verificationQAPairs != null &&
        verificationQAPairs.isNotEmpty) {
      await _repo.saveSecrets(postId: docId, qaPairs: verificationQAPairs);
    }

    if (post.category == 'found' && post.custody == 'admin') {
      await _notifyAdminOfDropOff(post, docId);
    }

    _runMatching(post, docId);
  }

  Future<void> _notifyAdminOfDropOff(PostModel post, String docId) async {
    try {
      final adminSnap = await _db
          .collection('profiles')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (adminSnap.docs.isEmpty) return;

      final adminUid = adminSnap.docs.first.id;

      await _db
          .collection('notifications')
          .doc(adminUid)
          .collection('items')
          .add({
        'title': '📦 New Item Dropped Off',
        'body':
        '${post.postedByName} dropped off "${post.title}" '
            '(${post.location}) for safekeeping.',
        'type': 'admin_dropoff',
        'postId': docId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _runMatching(PostModel post, String docId) async {
    try {
      matchLoading.value = true;

      final postData = {
        'title':         post.title,
        'description':   post.description,
        'location':      post.location,
        'category':      post.category,
        'imageUrl':      post.imageUrl,
        'urgencyLevel':  post.urgencyLevel,
        'custody':       post.custody,
        'postedByUid':   post.postedByUid,
        'postedByName':  post.postedByName,
        'postedByEmail': post.postedByEmail,
      };

      final result = await MatchingService.findMatches(postData, docId);

      latestMatch.value = result;

      if (result != null && result.isMatch) {
        _showMatchDialog(result);
      }
    } catch (e) {
      // Silent fail
    } finally {
      matchLoading.value = false;
    }
  }

  void _showMatchDialog(MatchResult result) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Match Found!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              if (result.matchedPost != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.matchedPost!['title'] ?? '',
                              style:
                              const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              result.matchedPost!['location'] ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                result.reason,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Both sides must complete ownership verification '
                      'before a chat opens.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    Get.toNamed('/notifications');
                  },
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('View Notification'),
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
    required String imageUrl,
    required String urgencyLevel,
  }) async {
    await _repo.updatePost(
      id:            id,
      title:         title,
      description:   description,
      location:      location,
      imageUrl:      imageUrl,
      urgencyLevel:  urgencyLevel,
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