// lib/modules/posts/post_item_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme.dart';
import '../../viewmodels/posts_controller.dart';
import '../../models/post_model.dart';
import '../../services/cloudinary_service.dart';
import '../../routes/app_routes.dart';
import '../../utils/snackbars.dart';

class PostItemScreen extends StatefulWidget {
  final PostModel? existingPost;

  const PostItemScreen({super.key, this.existingPost});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final PostsController postsC = Get.find<PostsController>();

  final titleC    = TextEditingController();
  final descC     = TextEditingController();
  final locationC = TextEditingController();

  String category     = 'lost';
  String urgencyLevel = 'low';
  bool loading         = false;

  Uint8List? selectedImageBytes;
  String existingImageUrl = '';

  @override
  void initState() {
    super.initState();
    if (widget.existingPost != null) {
      final p          = widget.existingPost!;
      titleC.text      = p.title;
      descC.text       = p.description;
      locationC.text   = p.location;
      category         = p.category;
      urgencyLevel     = p.urgencyLevel;
      existingImageUrl = p.imageUrl;
    }
  }

  @override
  void dispose() {
    titleC.dispose();
    descC.dispose();
    locationC.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker  = ImagePicker();
    final XFile? file =
    await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    selectedImageBytes = await file.readAsBytes();
    setState(() {});
  }

  Future<void> submit() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      AppSnackbar.warning('Please login first to post an item.');
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed(Routes.auth);
      });
      return;
    }

    if (titleC.text.trim().isEmpty) {
      AppSnackbar.warning('Please enter a title for your item.');
      return;
    }

    if (descC.text.trim().isEmpty) {
      AppSnackbar.warning('Please enter a description.');
      return;
    }

    setState(() => loading = true);

    try {
      String imgUrl = existingImageUrl;

      if (selectedImageBytes != null) {
        AppSnackbar.info('Uploading image... please wait ⏳');
        imgUrl =
            await CloudinaryService.uploadBytes(selectedImageBytes!) ??
                existingImageUrl;
      }

      if (widget.existingPost == null) {
        final post = PostModel(
          id:            '',
          title:         titleC.text.trim(),
          description:   descC.text.trim(),
          location:      locationC.text.trim(),
          category:      category,
          imageUrl:      imgUrl,
          urgencyLevel:  urgencyLevel,
          postedByUid:   user.uid,
          postedByName:  user.displayName ?? 'User',
          postedByEmail: user.email ?? '',
          createdAt:     DateTime.now(),
        );
        await postsC.addPost(post);
        AppSnackbar.success(
          category == 'lost'
              ? 'Lost item posted! We will notify you if a match is found 🔍'
              : 'Found item posted! We will notify the owner 🎉',
        );
        if (category == 'lost') {
          Get.offAllNamed(Routes.lost);
        } else {
          Get.offAllNamed(Routes.found);
        }
      } else {
        await postsC.updatePost(
          id:            widget.existingPost!.id,
          title:         titleC.text.trim(),
          description:   descC.text.trim(),
          location:      locationC.text.trim(),
          imageUrl:      imgUrl,
          urgencyLevel:  urgencyLevel,
        );
        AppSnackbar.success('Your post has been updated successfully ✅');
        Get.offAllNamed(Routes.myPosts);
      }
    } catch (e) {
      AppSnackbar.error('Failed to save post. Please try again.');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingPost != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? 'Edit Post'
            : category == 'lost'
            ? 'Report Lost Item'
            : 'Report Found Item'),
        backgroundColor: UniLostTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // CATEGORY TOGGLE
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Lost'),
                  selected: category == 'lost',
                  onSelected: (_) =>
                      setState(() => category = 'lost'),
                  selectedColor: Colors.red.shade100,
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Found'),
                  selected: category == 'found',
                  onSelected: (_) =>
                      setState(() => category = 'found'),
                  selectedColor: Colors.green.shade100,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // URGENCY LEVEL
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Urgency Level',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _urgencyChip('Low',    'low',    Colors.blue.shade100),
                const SizedBox(width: 8),
                _urgencyChip('Medium', 'medium', Colors.orange.shade100),
                const SizedBox(width: 8),
                _urgencyChip('High',   'high',   Colors.red.shade100),
              ],
            ),

            const SizedBox(height: 16),

            // IMAGE — small square preview like card
            Row(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: selectedImageBytes != null
                        ? ClipRRect(
                      borderRadius:
                      BorderRadius.circular(12),
                      child: Image.memory(
                        selectedImageBytes!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : existingImageUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius:
                      BorderRadius.circular(12),
                      child: Image.network(
                        existingImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                            _imagePlaceholder(),
                      ),
                    )
                        : _imagePlaceholder(),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Item Photo',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Add a clear photo to help with AI matching',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          size: 18,
                        ),
                        label: Text(
                          selectedImageBytes != null ||
                              existingImageUrl.isNotEmpty
                              ? 'Change Image'
                              : 'Select Image',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // TITLE
            TextField(
              controller: titleC,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Black leather wallet',
              ),
            ),

            const SizedBox(height: 12),

            // DESCRIPTION
            TextField(
              controller: descC,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the item in detail...',
              ),
            ),

            const SizedBox(height: 12),

            // LOCATION
            TextField(
              controller: locationC,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'e.g. Near cafeteria, Block C',
              ),
            ),

            const SizedBox(height: 24),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: UniLostTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: loading
                    ? const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Submitting...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                )
                    : Text(
                  isEditing ? 'Update Post' : 'Submit',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _urgencyChip(String label, String value, Color selectedColor) {
    return ChoiceChip(
      label: Text(label),
      selected: urgencyLevel == value,
      onSelected: (_) => setState(() => urgencyLevel = value),
      selectedColor: selectedColor,
    );
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 36,
          color: Colors.grey,
        ),
        SizedBox(height: 6),
        Text(
          'Tap to add',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}