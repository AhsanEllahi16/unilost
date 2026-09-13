// lib/repositories/posts_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostsRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<PostModel>> streamPosts() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList(),
    );
  }

  Future<String> addPost(PostModel post) async {
    final doc = await _db
        .collection('posts')
        .add(post.toFirestore());
    return doc.id;
  }

  // Saves up to 3 hidden Layer 1 verification Q&A pairs for a found
  // post. Stored as a list so the claimant can be asked several
  // questions instead of just one.
  Future<void> saveSecrets({
    required String postId,
    required List<Map<String, String>> qaPairs,
  }) async {
    await _db.collection('post_secrets').doc(postId).set({
      'questions': qaPairs, // [{ "question": "...", "answer": "..." }, ...]
    });
  }

  Future<void> updatePost({
    required String id,
    required String title,
    required String description,
    required String location,
    required String imageUrl,
    required String urgencyLevel,
  }) async {
    await _db.collection('posts').doc(id).update({
      'title':        title,
      'description':  description,
      'location':     location,
      'imageUrl':     imageUrl,
      'urgencyLevel': urgencyLevel,
    });
  }

  Future<void> deletePost(String id) async {
    await _db.collection('posts').doc(id).delete();
  }
}