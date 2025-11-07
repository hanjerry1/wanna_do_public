import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  final String uid;
  final String content;
  final String status;
  final Timestamp? createdAt;

  ContactModel({
    required this.uid,
    required this.content,
    required this.status,
    this.createdAt,
  });

  ContactModel.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        content = json['content'],
        status = json['status'],
        createdAt = json['createdAt'] as Timestamp?;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'content': content,
      'status': status,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
