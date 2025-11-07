import 'package:cloud_firestore/cloud_firestore.dart';

class RequestQueueModel {
  final String uid;
  final String deviceInfo;
  final Timestamp? createdAt;

  RequestQueueModel({
    required this.uid,
    required this.deviceInfo,
    this.createdAt,
  });

  RequestQueueModel.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        deviceInfo = json['deviceInfo'],
        createdAt = json['createdAt'] as Timestamp?;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'deviceInfo': deviceInfo,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
