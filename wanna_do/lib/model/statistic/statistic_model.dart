class StatisticModel {
  final String uid;
  final String name;
  final int totalChallenge;
  final int totalWin;
  final int totalLose;
  final int monthChallenge;
  final int monthWin;
  final int monthLose;
  final int totalMyLikePost;
  final int totalMyPost;
  final int monthMyPost;
  final int totalCheckup;
  final int monthCheckup;
  final int todayCheckup;
  final int monthPointOutTicket;
  final int totalMedal;

  StatisticModel({
    required this.uid,
    required this.name,
    required this.totalChallenge,
    required this.totalWin,
    required this.totalLose,
    required this.monthChallenge,
    required this.monthWin,
    required this.monthLose,
    required this.totalMyLikePost,
    required this.totalMyPost,
    required this.monthMyPost,
    required this.totalCheckup,
    required this.monthCheckup,
    required this.todayCheckup,
    required this.monthPointOutTicket,
    required this.totalMedal,
  });

  StatisticModel.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        name = json['name'],
        totalChallenge = json['totalChallenge'],
        totalWin = json['totalWin'],
        totalLose = json['totalLose'],
        monthChallenge = json['monthChallenge'],
        monthWin = json['monthWin'],
        monthLose = json['monthLose'],
        totalMyPost = json['totalMyPost'],
        totalMyLikePost = json['totalMyLikePost'],
        monthMyPost = json['monthMyPost'],
        totalCheckup = json['totalCheckup'],
        monthCheckup = json['monthCheckup'],
        todayCheckup = json['todayCheckup'],
        monthPointOutTicket = json['monthPointOutTicket'],
        totalMedal = json['totalMedal'];

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'totalChallenge': totalChallenge,
      'totalWin': totalWin,
      'totalLose': totalLose,
      'monthChallenge': monthChallenge,
      'monthWin': monthWin,
      'monthLose': monthLose,
      'totalMyPost': totalMyPost,
      'totalMyLikePost': totalMyLikePost,
      'monthMyPost': monthMyPost,
      'totalCheckup': totalCheckup,
      'monthCheckup': monthCheckup,
      'todayCheckup': todayCheckup,
      'monthPointOutTicket': monthPointOutTicket,
      'totalMedal': totalMedal,
    };
  }
}
