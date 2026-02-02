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

  Future<void> addPost(PostModel post) async {
    await _db.collection('posts').add(post.toFirestore());
  }

  Future<void> updatePost({
    required String id,
    required String title,
    required String description,
    required String location,
    required String image,
  }) async {
    await _db.collection('posts').doc(id).update({
      'title': title,
      'description': description,
      'location': location,
      'image': image,
    });
  }

  Future<void> deletePost(String id) async {
    await _db.collection('posts').doc(id).delete();
  }
}
