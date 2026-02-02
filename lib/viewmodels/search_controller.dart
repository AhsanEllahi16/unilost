import 'package:get/get.dart';
import '../models/post_model.dart';
import '../repositories/posts_repository.dart';

class SearchControllerX extends GetxController {
  final PostsRepository _repo;

  SearchControllerX(this._repo);

  /// 🔹 All posts stream cached locally
  final RxList<PostModel> _allPosts = <PostModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Listen once to repository stream
    _repo.streamPosts().listen((list) {
      _allPosts.assignAll(list);
    });
  }

  /// 🔹 Search logic
  List<PostModel> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _allPosts;

    return _allPosts.where((p) {
      return p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.location.toLowerCase().contains(q);
    }).toList();
  }

  /// 🔹 Tabs helpers
  List<PostModel> lostPosts(String query) =>
      search(query).where((p) => p.category == 'lost').toList();

  List<PostModel> foundPosts(String query) =>
      search(query).where((p) => p.category == 'found').toList();
}
