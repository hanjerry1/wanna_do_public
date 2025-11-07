import 'package:cloud_firestore/cloud_firestore.dart';

class UserStateLogModel {
  final String stateFrom;
  final String newState;
  final String previousState;
  final Timestamp? createdAt;

  UserStateLogModel({
    required this.stateFrom,
    required this.newState,
    required this.previousState,
    this.createdAt,
  });

  UserStateLogModel.fromJson(Map<String, dynamic> json)
      : stateFrom = json['stateFrom'],
        newState = json['newState'],
        previousState = json['previousState'],
        createdAt = json['createdAt'] as Timestamp?;

  Map<String, dynamic> toJson() {
    return {
      'stateFrom': stateFrom,
      'newState': newState,
      'previousState': previousState,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
