import 'package:get/get.dart';
import '../repositories/posts_repository.dart';
import '../models/post_model.dart';

class PostsController extends GetxController {
  final PostsRepository _repo;

  PostsController(this._repo);

  final posts = <PostModel>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> addPost(PostModel post) async {
    await _repo.addPost(post);
  }

  Future<void> updatePost({
    required String id,
    required String title,
    required String description,
    required String location,
    required String image,
  }) async {
    await _repo.updatePost(
      id: id,
      title: title,
      description: description,
      location: location,
      image: image,
    );
  }

  Future<void> deletePost(String id) async {
    await _repo.deletePost(id);
  }

  List<PostModel> myPosts(String uid) {
    return posts.where((p) => p.postedByUid == uid).toList();
  }

  /// 🔹 return only Lost items
  List<PostModel> lostPosts() {
    return posts.where((p) => p.category == "lost").toList();
  }

  /// 🔹 return only Found items
  List<PostModel> foundPosts() {
    return posts.where((p) => p.category == "found").toList();
  }
}
