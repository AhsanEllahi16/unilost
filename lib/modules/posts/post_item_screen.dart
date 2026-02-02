import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme.dart';
import '../../viewmodels/posts_controller.dart';
import '../../models/post_model.dart';
import '../../services/cloudinary_service.dart';

class PostItemScreen extends StatefulWidget {
  final PostModel? existingPost;

  const PostItemScreen({super.key, this.existingPost});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final PostsController postsC = Get.find<PostsController>();

  final titleC = TextEditingController();
  final descC = TextEditingController();
  final locationC = TextEditingController();

  String category = "lost";
  bool loading = false;

  Uint8List? selectedImageBytes; // <-- web/mobile safe

  @override
  void initState() {
    super.initState();

    if (widget.existingPost != null) {
      final p = widget.existingPost!;
      titleC.text = p.title;
      descC.text = p.description;
      locationC.text = p.location;
      category = p.category;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    selectedImageBytes = await file.readAsBytes();

    setState(() {});
  }

  Future<void> submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (titleC.text.isEmpty || descC.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    setState(() => loading = true);

    try {
      String imgUrl = "";

      // Upload only if new image selected
      if (selectedImageBytes != null) {
        imgUrl = await CloudinaryService.uploadBytes(selectedImageBytes!) ?? "";
      }

      if (widget.existingPost == null) {
        final post = PostModel(
          id: '',
          title: titleC.text,
          description: descC.text,
          location: locationC.text,
          category: category,
          image: imgUrl,
          postedByUid: user.uid,
          postedByName: user.displayName ?? 'User',
          postedByEmail: user.email ?? '',
          createdAt: DateTime.now(),
        );

        await postsC.addPost(post);
      } else {
        await postsC.updatePost(
          id: widget.existingPost!.id,
          title: titleC.text,
          description: descC.text,
          location: locationC.text,
          image: imgUrl.isEmpty ? widget.existingPost!.image : imgUrl,
        );
      }

      Get.back();
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category == "lost" ? "Report Lost Item" : "Report Found Item"),
        backgroundColor: UniLostTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Lost"),
                  selected: category == "lost",
                  onSelected: (_) => setState(() => category = "lost"),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text("Found"),
                  selected: category == "found",
                  onSelected: (_) => setState(() => category = "found"),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: selectedImageBytes == null
                  ? const Center(child: Text("No image selected"))
                  : Image.memory(selectedImageBytes!, fit: BoxFit.cover),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: pickImage,
                child: const Text("Select Image"),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: titleC,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descC,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: locationC,
              decoration: const InputDecoration(
                labelText: "Location",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: UniLostTheme.primary,
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
