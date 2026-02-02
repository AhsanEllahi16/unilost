import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../routes/app_routes.dart';
import '../../models/post_model.dart';

class ItemDetailScreen extends StatelessWidget {
  final PostModel? post;

  const ItemDetailScreen({
    super.key,
    this.post,
  });

  /// 🔹 Resolve post from constructor OR Get.arguments
  PostModel get _post {
    if (post != null) return post!;
    return Get.arguments as PostModel;
  }

  @override
  Widget build(BuildContext context) {
    final p = _post;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.title),
        backgroundColor: UniLostTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: _buildImage(p),
            ),

            const SizedBox(height: 20),

            // TITLE
            Text(
              p.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // DESCRIPTION
            Text(
              p.description,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 15),

            // LOCATION
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    p.location,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // CONTACT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(
                    Routes.chat,
                    arguments: {
                      'name': p.postedByName,
                      'email': p.postedByEmail,
                      'uid': p.postedByUid,
                    },
                  );
                },
                child: const Text('Contact'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// IMAGE BUILDER
  Widget _buildImage(PostModel p) {
    if (p.image.isEmpty) {
      return _placeholder();
    }

    if (p.image.startsWith('http')) {
      return Image.network(
        p.image,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return Image.asset(
      p.image,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 250,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.broken_image,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }
}
