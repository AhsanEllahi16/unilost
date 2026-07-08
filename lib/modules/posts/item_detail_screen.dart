// lib/modules/posts/item_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../routes/app_routes.dart';
import '../../models/post_model.dart';

class ItemDetailScreen extends StatelessWidget {
  final PostModel? post;

  const ItemDetailScreen({super.key, this.post});

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

            // ✅ IMAGE + BASIC INFO ROW (like card style)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Square image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImage(p, size: 120),
                ),
                const SizedBox(width: 16),

                // Info beside image
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: p.category == 'lost'
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          p.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: p.category == 'lost'
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        p.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              p.location,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Posted by
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'by ${p.postedByName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ DESCRIPTION CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.description,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ✅ DETAILS CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _detailRow(
                    context,
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: p.category.toUpperCase(),
                  ),
                  const Divider(height: 16),
                  _detailRow(
                    context,
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: p.location,
                  ),
                  const Divider(height: 16),
                  _detailRow(
                    context,
                    icon: Icons.person_outline,
                    label: 'Posted by',
                    value: p.postedByName,
                  ),
                  const Divider(height: 16),
                  _detailRow(
                    context,
                    icon: Icons.access_time,
                    label: 'Posted',
                    value: _timeAgo(p.createdAt),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ✅ CONTACT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed(
                    Routes.chat,
                    arguments: {
                      'chatWith': p.postedByName,
                      'uid':      p.postedByUid,
                    },
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Contact'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UniLostTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withOpacity(0.5),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.5),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildImage(PostModel p, {required double size}) {
    if (p.image.isNotEmpty && p.image.startsWith('http')) {
      return Image.network(
        p.image,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(size),
      );
    }
    if (p.image.isNotEmpty) {
      return Image.asset(
        p.image,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(size),
      );
    }
    return _placeholder(size);
  }

  Widget _placeholder(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.broken_image,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}