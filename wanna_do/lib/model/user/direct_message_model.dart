import 'package:cloud_firestore/cloud_firestore.dart';

class DirectMessageModel {
  final String title;
  final String content;
  final String status;
  final Timestamp? createdAt;

  DirectMessageModel({
    required this.title,
    required this.content,
    required this.status,
    this.createdAt,
  });

  DirectMessageModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        content = json['content'],
        status = json['status'],
        createdAt = json['createdAt'] as Timestamp?;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'status': status,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
