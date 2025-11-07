import 'package:cloud_firestore/cloud_firestore.dart';

class PointOutModel {
  final String uid;
  final String name;
  final String account;
  final String bank;
  final int point;
  final bool isFinish;
  final Timestamp? createdAt;

  PointOutModel({
    required this.uid,
    required this.name,
    required this.account,
    required this.bank,
    required this.point,
    required this.isFinish,
    this.createdAt,
  });

  PointOutModel.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        name = json['name'],
        account = json['account'],
        bank = json['bank'],
        point = json['point'],
        isFinish = json['isFinish'],
        createdAt = json['createdAt'] as Timestamp?;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'account': account,
      'bank': bank,
      'point': point,
      'isFinish': isFinish,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
