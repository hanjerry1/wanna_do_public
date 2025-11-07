import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteUserModel {
  final String uid;
  final String name;
  final String nickname;
  final String email;
  final String phone;
  final String birth;
  final Timestamp loginAt;
  final Timestamp signupAt;
  final Timestamp createdAt;

  DeleteUserModel({
    required this.uid,
    required this.name,
    required this.nickname,
    required this.email,
    required this.phone,
    required this.birth,
    required this.loginAt,
    required this.signupAt,
    required this.createdAt,
  });

  DeleteUserModel.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        name = json['name'],
        nickname = json['nickname'],
        email = json['email'],
        phone = json['phone'],
        birth = json['birth'],
        loginAt = json['loginAt'] as Timestamp,
        signupAt = json['signupAt'] as Timestamp,
        createdAt = json['createdAt'] as Timestamp;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'birth': birth,
      'loginAt': loginAt,
      'signupAt': signupAt,
      'createdAt': createdAt,
    };
  }
}
