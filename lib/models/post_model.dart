import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final String image;
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
    required this.image,
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
      image: d['image'] ?? '',
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
      'image': image,
      'postedByName': postedByName,
      'postedByUid': postedByUid,
      'postedByEmail': postedByEmail,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
