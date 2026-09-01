// lib/models/post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final String imageUrl;
  final String urgencyLevel; // 'low' | 'medium' | 'high'
  final String status;       // 'active' | 'matched' | 'resolved' | 'deleted'
  final String postedByName;
  final String postedByUid;
  final String postedByEmail;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.imageUrl,
    this.urgencyLevel = 'low',
    this.status = 'active',
    required this.postedByName,
    required this.postedByUid,
    required this.postedByEmail,
    required this.createdAt,
  });

  factory PostModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final d = doc.data()!;
    return PostModel(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      location: d['location'] ?? '',
      category: d['category'] ?? 'lost',
      // Falls back to the old 'image' field name for any posts created
      // before this rename, so existing data keeps working.
      imageUrl: d['imageUrl'] ?? d['image'] ?? '',
      urgencyLevel: d['urgencyLevel'] ?? 'low',
      status: d['status'] ?? 'active',
      postedByName: d['postedByName'] ?? '',
      postedByUid: d['postedByUid'] ?? '',
      postedByEmail: d['postedByEmail'] ?? '',
      createdAt:
      (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'category': category,
      'imageUrl': imageUrl,
      'urgencyLevel': urgencyLevel,
      'status': status,
      'postedByName': postedByName,
      'postedByUid': postedByUid,
      'postedByEmail': postedByEmail,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}