import 'package:cloud_firestore/cloud_firestore.dart';

// lib/model/user_model.dart
class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? photoUrl;
  final bool isOnline;
  

  UserModel({
    required this.uid,
    required this.name,
    required this.email, required this.createdAt, required this.updatedAt, this.photoUrl, this.isOnline = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "photoUrl": photoUrl,
      "isOnline": isOnline,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '', 
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      photoUrl: map['photoUrl'],
      isOnline: map['isOnline'] ?? false,
    );
  }
}
