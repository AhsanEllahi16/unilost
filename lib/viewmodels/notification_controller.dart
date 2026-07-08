// lib/viewmodels/notification_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
  final RxList<NotificationModel> notifications =
      <NotificationModel>[].obs;

  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    // ✅ Listen to auth state
    // When user logs in → load their real notifications
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _startStream(user.uid);
      } else {
        notifications.clear();
        _sub?.cancel();
      }
    });
  }

  // ✅ Real-time stream from Firestore
  void _startStream(String uid) {
    _sub?.cancel();

    _sub = FirebaseFirestore.instance
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snap) {
        final list = snap.docs.map((doc) {
          final data = doc.data();
          return NotificationModel(
            id:        doc.id,
            title:     data['title']     ?? '',
            body:      data['body']      ?? '',
            createdAt: (data['createdAt'] as dynamic)
                ?.toDate() ??
                DateTime.now(),
            read:      data['read']      ?? false,
          );
        }).toList();

        notifications.assignAll(list);
      },
      onError: (e) {
        // Silent fail — notifications not critical
      },
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  // ✅ Mark single notification as read in Firestore
  Future<void> markRead(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(user.uid)
        .collection('items')
        .doc(id)
        .update({'read': true});

    // Update local list immediately
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = NotificationModel(
        id:        notifications[index].id,
        title:     notifications[index].title,
        body:      notifications[index].body,
        createdAt: notifications[index].createdAt,
        read:      true,
      );
    }
  }

  // ✅ Clear all notifications from Firestore
  Future<void> clearAll() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(user.uid)
        .collection('items')
        .get();

    for (final doc in snap.docs) {
      await doc.reference.delete();
    }

    notifications.clear();
  }

  // Unread count
  int get unreadCount =>
      notifications.where((n) => !n.read).length;
}