import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String docId;
  final String uid;
  final String nickname;
  final String unKnownName;
  final String content;
  final String reportState;
  final List<String>? likeUids;
  final int likeCount;
  final bool isUnknown;
  final Timestamp? createdAt;

  ChatModel({
    required this.docId,
    required this.uid,
    required this.nickname,
    required this.unKnownName,
    required this.content,
    required this.reportState,
    this.likeUids,
    required this.isUnknown,
    required this.likeCount,
    this.createdAt,
  });

  ChatModel.fromJson(Map<String, dynamic> json)
      : docId = json['docId'],
        uid = json['uid'],
        nickname = json['nickname'],
        unKnownName = json['unKnownName'],
        content = json['content'],
        reportState = json['reportState'],
        likeUids = List<String>.from(json['likeUids'] ?? []),
        isUnknown = json['isUnknown'],
        likeCount = json['likeCount'],
        createdAt = json['createdAt'] as Timestamp?;

  Map<String, dynamic> toJson() {
    return {
      'docId': docId,
      'uid': uid,
      'nickname': nickname,
      'unKnownName': unKnownName,
      'content': content,
      'reportState': reportState,
      'likeUids': likeUids,
      'isUnknown': isUnknown,
      'likeCount': likeCount,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
