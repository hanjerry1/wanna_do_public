import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeModel {
  final String docId;
  final String uid;
  final String receiptId;
  final String category;
  final String goal;
  final String status;
  final List<String>? certifyUrl;
  final String? thumbNailUrl;
  final String? checker;
  final String? failReason;
  final String? complainReason;
  final String reportState;
  final String? checkingState;
  final String pointState;
  final bool? isVideo;
  final bool isVisible;
  final bool paymentAgree;
  final int betPoint;
  final Timestamp deadline;
  final Timestamp? checkAt;
  final Timestamp? certifyAt;
  final Timestamp? applyAt;

  ChallengeModel({
    required this.docId,
    required this.uid,
    required this.receiptId,
    required this.category,
    required this.goal,
    required this.status,
    this.certifyUrl,
    this.thumbNailUrl,
    this.checker,
    this.failReason,
    this.complainReason,
    required this.reportState,
    this.checkingState,
    required this.pointState,
    this.isVideo,
    required this.isVisible,
    required this.paymentAgree,
    required this.betPoint,
    required this.deadline,
    this.checkAt,
    this.certifyAt,
    this.applyAt,
  });

  ChallengeModel.fromJson(Map<String, dynamic> json)
      : docId = json['docId'],
        uid = json['uid'],
        receiptId = json['receiptId'],
        category = json['category'],
        goal = json['goal'],
        status = json['status'],
        certifyUrl = List<String>.from(json['certifyUrl'] ?? []),
        thumbNailUrl = json['thumbNailUrl'],
        checker = json['checker'],
        failReason = json['failReason'],
        complainReason = json['complainReason'],
        reportState = json['reportState'],
        checkingState = json['checkingState'],
        pointState = json['pointState'],
        isVideo = json['isVideo'],
        isVisible = json['isVisible'],
        paymentAgree = json['paymentAgree'],
        betPoint = json['betPoint'],
        deadline = json['deadline'] as Timestamp,
        checkAt = json['checkAt'] as Timestamp?,
        certifyAt = json['certifyAt'] as Timestamp?,
        applyAt = json['applyAt'] as Timestamp?;

  Map<String, dynamic> toJson() {
    return {
      'docId': docId,
      'uid': uid,
      'receiptId': receiptId,
      'category': category,
      'goal': goal,
      'status': status,
      'certifyUrl': certifyUrl,
      'thumbNailUrl': thumbNailUrl,
      'checker': checker,
      'failReason': failReason,
      'complainReason': complainReason,
      'reportState': reportState,
      'checkingState': checkingState,
      'pointState': pointState,
      'isVideo': isVideo,
      'isVisible': isVisible,
      'paymentAgree': paymentAgree,
      'betPoint': betPoint,
      'deadline': deadline,
      'checkAt': checkAt,
      'certifyAt': certifyAt,
      'applyAt': applyAt ?? FieldValue.serverTimestamp(),
    };
  }
}
