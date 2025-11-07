import 'package:cloud_firestore/cloud_firestore.dart';

class LikeModel {
  final String uid;
  final Timestamp? createdAt;

  LikeModel({
    required this.uid,
    this.createdAt,
  });

  LikeModel.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        createdAt = json['createdAt'] as Timestamp?;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
