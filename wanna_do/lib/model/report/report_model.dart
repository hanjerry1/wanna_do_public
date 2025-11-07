import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String? docId;
  final String? postId;
  final String reporterUid;
  final String reportedUid;
  final String reportReason;
  final String? chatId;
  final String? title;
  final String? content;
  final String? chat;
  final String? category;
  final String? goal;
  final String? status;
  final String? certifyUrl;
  final bool? isVisible;
  final int? betPoint;
  final Timestamp? deadline;
  final Timestamp? certifyAt;
  final Timestamp? applyAt;
  final Timestamp? postAt;
  final Timestamp? createdAt;

  ReportModel({
    this.docId,
    this.postId,
    required this.reporterUid,
    required this.reportedUid,
    required this.reportReason,
    this.chat,
    this.chatId,
    this.postAt,
    this.title,
    this.content,
    this.category,
    this.goal,
    this.status,
    this.certifyUrl,
    this.isVisible,
    this.betPoint,
    this.deadline,
    this.certifyAt,
    this.applyAt,
    this.createdAt,
  });

  ReportModel.fromJson(Map<String, dynamic> json)
      : postId = json['postId'],
        docId = json['docId'],
        reporterUid = json['reporterUid'],
        reportedUid = json['reportedUid'],
        reportReason = json['reportReason'],
        chatId = json['chatId'],
        title = json['title'],
        content = json['content'],
        chat = json['chat'],
        category = json['category'],
        goal = json['goal'],
        status = json['status'],
        certifyUrl = json['certifyUrl'],
        isVisible = json['isVisible'],
        betPoint = json['betPoint'],
        deadline = json['deadline'] as Timestamp?,
        certifyAt = json['certifyAt'] as Timestamp?,
        applyAt = json['applyAt'] as Timestamp?,
        postAt = json['postAt'] as Timestamp?,
        createdAt = json['createdAt'] as Timestamp?;

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'docId': docId,
      'chatId': chatId,
      'reporterUid': reporterUid,
      'reportedUid': reportedUid,
      'reportReason': reportReason,
      'title': title,
      'content': content,
      'chat': chat,
      'category': category,
      'goal': goal,
      'status': status,
      'certifyUrl': certifyUrl,
      'isVisible': isVisible,
      'betPoint': betPoint,
      'deadline': deadline,
      'certifyAt': certifyAt,
      'applyAt': applyAt,
      'postAt': postAt,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
