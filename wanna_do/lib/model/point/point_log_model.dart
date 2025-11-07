import 'package:cloud_firestore/cloud_firestore.dart';

class PointLogModel {
  final String uid;
  final String inout;
  final String pointFrom;
  final String? thatDocId;
  final int point;
  final Timestamp? createdAt;

  PointLogModel({
    required this.uid,
    required this.inout,
    required this.pointFrom,
    this.thatDocId,
    required this.point,
    this.createdAt,
  });

  PointLogModel.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        inout = json['inout'],
        pointFrom = json['pointFrom'],
        thatDocId = json['thatDocId'],
        point = json['point'],
        createdAt = json['createdAt'] as Timestamp?;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'inout': inout,
      'pointFrom': pointFrom,
      'thatDocId': thatDocId,
      'point': point,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
