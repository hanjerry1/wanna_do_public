import 'package:cloud_firestore/cloud_firestore.dart';

class SpaceModel {
  final String docId;
  final String uid;
  final String category;
  final String nickname;
  final String title;
  final String content;
  final List<String>? postUrl;
  final List<String>? chatUids;
  final List<String>? likeUids;
  final String reportState;
  final bool isUnknown;
  final int chatCount;
  final int likeCount;
  final Timestamp? editAt;
  final Timestamp? createdAt;

  SpaceModel({
    required this.docId,
    required this.uid,
    required this.category,
    required this.nickname,
    required this.title,
    required this.content,
    this.postUrl,
    this.chatUids,
    this.likeUids,
    required this.reportState,
    required this.isUnknown,
    required this.chatCount,
    required this.likeCount,
    this.editAt,
    this.createdAt,
  });

  SpaceModel.fromJson(Map<String, dynamic> json)
      : docId = json['docId'],
        uid = json['uid'],
        category = json['category'],
        nickname = json['nickname'],
        title = json['title'],
        content = json['content'],
        postUrl = List<String>.from(json['postUrl'] ?? []),
        chatUids = List<String>.from(json['chatUids'] ?? []),
        likeUids = List<String>.from(json['likeUids'] ?? []),
        reportState = json['reportState'],
        isUnknown = json['isUnknown'],
        chatCount = json['chatCount'],
        likeCount = json['likeCount'],
        editAt = parseTimestampAlgolia(json['editAt']),
        createdAt = parseTimestampAlgolia(json['createdAt']);

  static Timestamp? parseTimestampAlgolia(dynamic value) {
    if (value is Timestamp) {
      return value;
    } else if (value is int) {
      return Timestamp.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      return Timestamp.fromDate(DateTime.parse(value));
    } else {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'docId': docId,
      'uid': uid,
      'category': category,
      'nickname': nickname,
      'title': title,
      'content': content,
      'postUrl': postUrl,
      'chatUids': chatUids,
      'likeUids': likeUids,
      'reportState': reportState,
      'isUnknown': isUnknown,
      'chatCount': chatCount,
      'likeCount': likeCount,
      'editAt': editAt,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
