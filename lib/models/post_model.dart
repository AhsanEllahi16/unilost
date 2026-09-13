// lib/models/post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final String imageUrl;
  final String urgencyLevel;
  final String status;
  final String custody;
  final bool dropOffConfirmedByFinder;
  final bool dropOffReceivedByAdmin;
  final String? disposalReceipt;
  final DateTime? disposedAt;
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
    this.custody = 'finder',
    this.dropOffConfirmedByFinder = false,
    this.dropOffReceivedByAdmin = false,
    this.disposalReceipt,
    this.disposedAt,
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
      imageUrl: d['imageUrl'] ?? d['image'] ?? '',
      urgencyLevel: d['urgencyLevel'] ?? 'low',
      status: d['status'] ?? 'active',
      custody: d['custody'] ?? 'finder',
      dropOffConfirmedByFinder: d['dropOffConfirmedByFinder'] ?? false,
      dropOffReceivedByAdmin: d['dropOffReceivedByAdmin'] ?? false,
      disposalReceipt: d['disposalReceipt'],
      disposedAt: (d['disposedAt'] as Timestamp?)?.toDate(),
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
      'custody': custody,
      'dropOffConfirmedByFinder':
      custody == 'admin' ? dropOffConfirmedByFinder : false,
      'dropOffReceivedByAdmin':
      custody == 'admin' ? dropOffReceivedByAdmin : false,
      if (disposalReceipt != null) 'disposalReceipt': disposalReceipt,
      if (disposedAt != null) 'disposedAt': Timestamp.fromDate(disposedAt!),
      'postedByName': postedByName,
      'postedByUid': postedByUid,
      'postedByEmail': postedByEmail,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}