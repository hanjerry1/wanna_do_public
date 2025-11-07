import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? name;
  final String? nickname;
  final String? email;
  final String? phone;
  final String? birth;
  final String? gender;
  final String? deviceId;
  final String? fcmToken;
  final String? appleUid;
  final String? whereLogin;
  final Timestamp? loginAt;
  final Timestamp? createdAt;

  UserModel({
    required this.uid,
    this.name,
    this.nickname,
    this.email,
    this.phone,
    this.birth,
    this.gender,
    this.deviceId,
    this.fcmToken,
    this.appleUid,
    this.whereLogin,
    this.loginAt,
    this.createdAt,
  });

  UserModel.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        name = json['name'] ?? '',
        nickname = json['nickname'] ?? '',
        email = json['email'] ?? '',
        phone = json['phone'] ?? '',
        birth = json['birth'] ?? '',
        gender = json['gender'] ?? '',
        deviceId = json['deviceId'] ?? '',
        fcmToken = json['fcmToken'] ?? '',
        appleUid = json['appleUid'] ?? '',
        whereLogin = json['whereLogin'] ?? '',
        loginAt = parseTimestampAlgolia(json['loginAt']),
        createdAt = parseTimestampAlgolia(json['createdAt']);

  // 알고리아(데이터 색인 프로그램)를 쓰면 datetime타입 인식을 못하는 문제가 있음.
  // 그래서 이렇게 변환이 필요함.
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
      'uid': uid,
      'name': name,
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'birth': birth,
      'gender': gender,
      'deviceId': deviceId,
      'fcmToken': fcmToken,
      'appleUid': appleUid,
      'whereLogin': whereLogin,
      'loginAt': loginAt ?? FieldValue.serverTimestamp(),
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
