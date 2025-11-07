import 'package:cloud_firestore/cloud_firestore.dart';

class MonthRankModel {
  final String uid;
  final String name;
  final int monthWin;
  final int monthLose;
  final int monthChallenge;
  final int monthCheckup;
  final int monthMyPost;
  final int monthPointOutTicket;
  final int monthScore;
  final Timestamp createdAt;

  MonthRankModel({
    required this.uid,
    required this.name,
    required this.monthWin,
    required this.monthLose,
    required this.monthChallenge,
    required this.monthCheckup,
    required this.monthMyPost,
    required this.monthPointOutTicket,
    required this.createdAt,
    required this.monthScore,
  });

  MonthRankModel.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        name = json['name'],
        monthWin = json['monthWin'],
        monthLose = json['monthLose'],
        monthChallenge = json['monthChallenge'],
        monthCheckup = json['monthCheckup'],
        monthMyPost = json['monthMyPost'],
        monthPointOutTicket = json['monthPointOutTicket'],
        createdAt = json['createdAt'] as Timestamp,
        monthScore = json['monthScore'];

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'monthWin': monthWin,
      'monthLose': monthLose,
      'monthChallenge': monthChallenge,
      'monthCheckup': monthCheckup,
      'monthMyPost': monthMyPost,
      'monthPointOutTicket': monthPointOutTicket,
      'createdAt': createdAt,
      'monthScore': monthScore,
    };
  }
}
