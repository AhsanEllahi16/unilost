import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? rollNo;
  final String? avatarUrl;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.rollNo,
    this.avatarUrl,
  });

  factory ProfileModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return ProfileModel(
      id: doc.id,
      name: data["name"] ?? "",
      email: data["email"] ?? "",
      phone: data["phone"],
      rollNo: data["rollNo"],
      avatarUrl: data["avatarUrl"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "rollNo": rollNo,
      "avatarUrl": avatarUrl,
    };
  }

  // 👇 VERY IMPORTANT method for MVVM state update
  ProfileModel copyWith({
    String? name,
    String? phone,
    String? rollNo,
    String? avatarUrl,
  }) {
    return ProfileModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      rollNo: rollNo ?? this.rollNo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
