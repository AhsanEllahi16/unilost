// lib/modules/posts/item_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../routes/app_routes.dart';
import '../../models/post_model.dart';

class ItemDetailScreen extends StatefulWidget {
  final PostModel? post;

  const ItemDetailScreen({super.key, this.post});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _isAdmin = false;
  bool _checkingAdmin = true;
  bool _busy = false;

  PostModel get _post {
    if (widget.post != null) return widget.post!;
    return Get.arguments as PostModel;
  }

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
  }

  Future<void> _checkIfAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _checkingAdmin = false);
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('profiles')
        .doc(user.uid)
        .get();
    setState(() {
      _isAdmin = doc.data()?['role'] == 'admin';
      _checkingAdmin = false;
    });
  }

  Future<void> _finderConfirmsDropOff() async {
    setState(() => _busy = true);
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(_post.id)
          .update({'dropOffConfirmedByFinder': true});
      Get.snackbar(
        'Confirmed',
        'You marked this item as submitted to admin.',
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() {});
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not confirm drop-off. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _adminConfirmsReceived() async {
    setState(() => _busy = true);
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(_post.id)
          .update({'dropOffReceivedByAdmin': true});
      Get.snackbar(
        'Confirmed',
        'You marked this item as received.',
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() {});
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not confirm receipt. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _post;
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bool isMyFoundPost =
        p.category == 'found' && p.postedByUid == myUid;
    final bool isMyOwnPost = p.postedByUid == myUid;

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

            if (p.category == 'found' && p.custody == 'admin')
              _buildAdminCustodyBanner(context, p),

            if (isMyFoundPost &&
                p.custody == 'admin' &&
                !p.dropOffConfirmedByFinder)
              _actionCard(
                icon: Icons.local_shipping_outlined,
                color: Colors.orange,
                text:
                'Have you physically dropped this item off with '
                    'admin yet?',
                buttonLabel: 'Yes, I submitted it',
                onPressed: _busy ? null : _finderConfirmsDropOff,
              ),

            if (!_checkingAdmin &&
                _isAdmin &&
                p.category == 'found' &&
                p.custody == 'admin' &&
                p.dropOffConfirmedByFinder &&
                !p.dropOffReceivedByAdmin)
              _actionCard(
                icon: Icons.inventory_2_outlined,
                color: Colors.indigo,
                text:
                'The finder says they submitted this item. Have you '
                    'received it at your office?',
                buttonLabel: 'Yes, I received it',
                onPressed: _busy ? null : _adminConfirmsReceived,
              ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImage(p, size: 120),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
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
                          if (p.category == 'lost')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _urgencyColor(p.urgencyLevel)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${p.urgencyLevel.toUpperCase()} URGENCY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _urgencyColor(p.urgencyLevel),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        p.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.blue),
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
                      Row(
                        children: [
                          const Icon(Icons.person_outline,
                              size: 16, color: Colors.grey),
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
                  Text(p.description, style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _detailRow(context,
                      icon: Icons.category_outlined,
                      label: 'Category',
                      value: p.category.toUpperCase()),
                  if (p.category == 'lost') ...[
                    const Divider(height: 16),
                    _detailRow(context,
                        icon: Icons.priority_high,
                        label: 'Urgency',
                        value: p.urgencyLevel.toUpperCase()),
                  ],
                  const Divider(height: 16),
                  _detailRow(context,
                      icon: Icons.info_outline,
                      label: 'Status',
                      value: p.status.toUpperCase()),
                  if (p.category == 'found') ...[
                    const Divider(height: 16),
                    _detailRow(context,
                        icon: Icons.local_police_outlined,
                        label: 'Held By',
                        value: p.custody == 'admin' ? 'ADMIN' : 'FINDER'),
                  ],
                  if (p.category == 'found' && p.custody == 'admin') ...[
                    const Divider(height: 16),
                    _detailRow(context,
                        icon: Icons.local_shipping_outlined,
                        label: 'Dropped Off',
                        value: p.dropOffConfirmedByFinder ? 'YES' : 'PENDING'),
                    const Divider(height: 16),
                    _detailRow(context,
                        icon: Icons.inventory_2_outlined,
                        label: 'Received by Admin',
                        value: p.dropOffReceivedByAdmin ? 'YES' : 'PENDING'),
                  ],
                  const Divider(height: 16),
                  _detailRow(context,
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: p.location),
                  const Divider(height: 16),
                  _detailRow(context,
                      icon: Icons.person_outline,
                      label: 'Posted by',
                      value: p.postedByName),
                  const Divider(height: 16),
                  _detailRow(context,
                      icon: Icons.access_time,
                      label: 'Posted',
                      value: _timeAgo(p.createdAt)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── FOUND ITEMS: only entry point is "Claim it", which
            // starts ownership verification. No Contact/chat shortcut
            // exists — chat only opens AFTER verification passes.
            if (p.category == 'found' && !isMyOwnPost)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.toNamed(
                      Routes.verification,
                      arguments: {
                        'foundPostId': p.id,
                        'finderUid': p.postedByUid,
                        'custody': p.custody,
                        'matchId': null,
                        'lostPostId': null,
                      },
                    );
                  },
                  icon: const Icon(Icons.verified_user_outlined),
                  label: const Text('This is mine — Claim it'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: UniLostTheme.primary,
                    side: const BorderSide(color: UniLostTheme.primary),
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),

            // ── LOST ITEMS: no direct Contact/chat button either.
            // Anyone with the item should post it as a Found item and
            // let AI matching + verification handle it, keeping every
            // ownership exchange in the app going through the same
            // verified pipeline.

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCustodyBanner(BuildContext context, PostModel p) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.local_police_outlined,
              size: 18, color: Colors.indigo.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              p.dropOffReceivedByAdmin
                  ? 'This item is confirmed held by the Lost & Found '
                  'admin office.'
                  : 'This item is being dropped off with the Lost & '
                  'Found admin office.',
              style: TextStyle(fontSize: 12, color: Colors.indigo.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required Color color,
    required String text,
    required String buttonLabel,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(text, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }

  Color _urgencyColor(String level) {
    switch (level) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Widget _detailRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    return Row(
      children: [
        Icon(icon,
            size: 18,
            color:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5))),
        const Spacer(),
        Text(value,
            style:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
    if (p.imageUrl.isNotEmpty && p.imageUrl.startsWith('http')) {
      return Image.network(
        p.imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(size),
      );
    }
    if (p.imageUrl.isNotEmpty) {
      return Image.asset(
        p.imageUrl,
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
      child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
    );
  }
}