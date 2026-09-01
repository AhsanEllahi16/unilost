// lib/widgets/item_card.dart
import 'package:flutter/material.dart';
import '../models/post_model.dart';

class ItemCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ItemCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft:    Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: _buildImage(context),
            ),

            // DETAILS
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // CATEGORY BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: post.category == 'lost'
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        post.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: post.category == 'lost'
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // TITLE
                    Text(
                      post.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // LOCATION
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            post.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // POSTED BY
                    Text(
                      'by ${post.postedByName}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (post.imageUrl.isNotEmpty && post.imageUrl.startsWith('http')) {
      return Image.network(
        post.imageUrl,
        width: 110,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }

    if (post.imageUrl.isNotEmpty) {
      return Image.asset(
        post.imageUrl,
        width: 110,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }

    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: 110,
      height: 100,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Icon(
        Icons.broken_image,
        size: 36,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}