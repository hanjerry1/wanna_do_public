import 'package:cloud_firestore/cloud_firestore.dart';

class CheckupRecordModel {
  final String thatDocId;
  final String uid;
  final String goal;
  final String category;
  final String status;
  final String pointState;
  final int betPoint;
  final Timestamp? createdAt;

  CheckupRecordModel({
    required this.thatDocId,
    required this.uid,
    required this.goal,
    required this.category,
    required this.status,
    required this.pointState,
    required this.betPoint,
    this.createdAt,
  });

  CheckupRecordModel.fromJson(Map<String, dynamic> json)
      : thatDocId = json['thatDocId'],
        uid = json['uid'],
        goal = json['goal'],
        category = json['category'],
        status = json['status'],
        pointState = json['pointState'],
        betPoint = json['betPoint'],
        createdAt = json['createdAt'] as Timestamp?;

  Map<String, dynamic> toJson() {
    return {
      'thatDocId': thatDocId,
      'uid': uid,
      'goal': goal,
      'category': category,
      'status': status,
      'pointState': pointState,
      'betPoint': betPoint,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
