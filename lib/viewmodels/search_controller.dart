// lib/viewmodels/search_controller.dart
import 'package:get/get.dart';
import '../models/post_model.dart';
import '../repositories/posts_repository.dart';
import 'posts_controller.dart';

class SearchControllerX extends GetxController {
  // ✅ Keep repo in constructor to satisfy InitialBinding
  // but we don't open a new stream from it
  final PostsRepository _repo;

  SearchControllerX(this._repo);

  // ✅ Reuse PostsController's already-loaded list
  // No new Firestore stream needed
  PostsController get _postsC => Get.find<PostsController>();

  List<PostModel> get _allPosts => _postsC.posts;

  /// Search across all posts by title, description or location
  List<PostModel> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _allPosts;

    return _allPosts.where((p) {
      return p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.location.toLowerCase().contains(q);
    }).toList();
  }

  /// Lost posts filtered by search query
  List<PostModel> lostPosts(String query) =>
      search(query).where((p) => p.category == 'lost').toList();

  /// Found posts filtered by search query
  List<PostModel> foundPosts(String query) =>
      search(query).where((p) => p.category == 'found').toList();
}