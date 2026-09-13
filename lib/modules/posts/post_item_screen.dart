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
  // Which category to preselect for a NEW post — ignored when editing.
  final String initialCategory;

  const PostItemScreen({
    super.key,
    this.existingPost,
    this.initialCategory = 'lost',
  });

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _QAControllerPair {
  final TextEditingController question = TextEditingController();
  final TextEditingController answer   = TextEditingController();

  void dispose() {
    question.dispose();
    answer.dispose();
  }
}

class _PostItemScreenState extends State<PostItemScreen> {
  final PostsController postsC = Get.find<PostsController>();

  final titleC    = TextEditingController();
  final descC     = TextEditingController();
  final locationC = TextEditingController();

  static const int maxQuestions = 3;
  final List<_QAControllerPair> qaControllers = [_QAControllerPair()];

  late String category;
  String urgencyLevel = 'low';
  String custody       = 'finder';
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
    } else {
      category = widget.initialCategory;
    }
  }

  @override
  void dispose() {
    titleC.dispose();
    descC.dispose();
    locationC.dispose();
    for (final c in qaControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    if (qaControllers.length >= maxQuestions) return;
    setState(() => qaControllers.add(_QAControllerPair()));
  }

  void _removeQuestion(int index) {
    if (qaControllers.length <= 1) return;
    setState(() {
      qaControllers[index].dispose();
      qaControllers.removeAt(index);
    });
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

    final bool isNewFoundPost =
        widget.existingPost == null && category == 'found';

    List<Map<String, String>> qaPairs = [];

    if (isNewFoundPost) {
      for (final pair in qaControllers) {
        final q = pair.question.text.trim();
        final a = pair.answer.text.trim();
        if (q.isNotEmpty && a.isNotEmpty) {
          qaPairs.add({'question': q, 'answer': a});
        }
      }
      if (qaPairs.isEmpty) {
        AppSnackbar.warning(
          'Please add at least one verification question and answer — '
              'this confirms the real owner when someone claims this item.',
        );
        return;
      }
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
          urgencyLevel:  category == 'lost' ? urgencyLevel : 'low',
          custody:       category == 'found' ? custody : 'finder',
          postedByUid:   user.uid,
          postedByName:  user.displayName ?? 'User',
          postedByEmail: user.email ?? '',
          createdAt:     DateTime.now(),
        );
        await postsC.addPost(
          post,
          verificationQAPairs: isNewFoundPost ? qaPairs : null,
        );
        AppSnackbar.success(
          category == 'lost'
              ? 'Lost item posted! We will notify you if a match is found 🔍'
              : custody == 'admin'
              ? 'Found item posted and marked as dropped off with admin ✅'
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
          urgencyLevel:  category == 'lost' ? urgencyLevel : 'low',
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
    final showCustodyChoice = !isEditing && category == 'found';
    final showVerificationFields = !isEditing && category == 'found';
    final showUrgency = category == 'lost';

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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Lost'),
                  selected: category == 'lost',
                  onSelected: isEditing
                      ? null
                      : (_) => setState(() => category = 'lost'),
                  selectedColor: Colors.red.shade100,
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Found'),
                  selected: category == 'found',
                  onSelected: isEditing
                      ? null
                      : (_) => setState(() => category = 'found'),
                  selectedColor: Colors.green.shade100,
                ),
              ],
            ),

            if (showUrgency) ...[
              const SizedBox(height: 16),
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
            ],

            if (showCustodyChoice) ...[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'What do you want to do with this item?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                value: 'finder',
                groupValue: custody,
                onChanged: (v) => setState(() => custody = v!),
                title: const Text("I'll hold onto it"),
                subtitle: const Text(
                  "You'll coordinate the handover directly once matched.",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                value: 'admin',
                groupValue: custody,
                onChanged: (v) => setState(() => custody = v!),
                title: const Text('Hand it to admin now'),
                subtitle: const Text(
                  "Drop it off with the Lost & Found office right away.",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              if (custody == 'admin')
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: const Text(
                    '⚠️ Please physically drop this item off with the '
                        'admin/Lost & Found office as soon as you submit '
                        'this post.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],

            const SizedBox(height: 16),

            Row(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: selectedImageBytes != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        selectedImageBytes!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : existingImageUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        existingImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      ),
                    )
                        : _imagePlaceholder(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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

            TextField(
              controller: titleC,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Black leather wallet',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descC,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the item in detail...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationC,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'e.g. Near cafeteria, Block C',
              ),
            ),

            if (showVerificationFields) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Verification Questions (at least 1 required)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  if (qaControllers.length < maxQuestions)
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: UniLostTheme.primary,
                      tooltip: 'Add another question',
                      onPressed: _addQuestion,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Ask something only the real owner would know — these "
                    "stay hidden and are never shown publicly. You can add "
                    "up to $maxQuestions questions; a claimant will need to "
                    "get most of them right.",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < qaControllers.length; i++)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Question ${i + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const Spacer(),
                          if (qaControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              color: Colors.red.shade300,
                              onPressed: () => _removeQuestion(i),
                            ),
                        ],
                      ),
                      TextField(
                        controller: qaControllers[i].question,
                        decoration: const InputDecoration(
                          labelText: 'Question',
                          hintText: 'e.g. What was inside the side pocket?',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: qaControllers[i].answer,
                        decoration: const InputDecoration(
                          labelText: 'Correct Answer',
                          hintText: 'e.g. An expired student ID',
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            const SizedBox(height: 24),

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
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    Text('Submitting...', style: TextStyle(fontSize: 16)),
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
        Icon(Icons.add_photo_alternate_outlined, size: 36, color: Colors.grey),
        SizedBox(height: 6),
        Text('Tap to add', style: TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}