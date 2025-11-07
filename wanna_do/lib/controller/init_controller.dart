import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanna_do/model/challenge/challenge_model.dart';
import 'package:wanna_do/model/checkup/checkup_log_model.dart';
import 'package:wanna_do/model/point/point_log_model.dart';

class InitDeadlineOverChangeController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      getInternetDateTimeDio().then((internetTime) {
        initOnceDeadlineOverChange(internetTime);
      }).catchError((error) {
        print(error);
      });
    }
  }

  Future<DateTime> getInternetDateTimeDio() async {
    var dio = Dio();
    var url = 'https://worldtimeapi.org/api/timezone/Asia/Seoul';

    try {
      var response = await dio.get(url);
      String dateTime = response.data['datetime'];
      DateTime now = DateTime.parse(dateTime);
      return now.toLocal();
    } catch (e) {
      return DateTime.now();
    }
  }

  void initOnceDeadlineOverChange(DateTime internetTime) async {
    try {
      String authUid = FirebaseAuth.instance.currentUser!.uid;
      var challengeRef = FirebaseFirestore.instance
          .collection('challenge')
          .doc(authUid)
          .collection('challenge');

      QuerySnapshot querySnapshot = await challengeRef
          .where('status', isEqualTo: 'apply')
          .where('deadline', isLessThan: Timestamp.fromDate(internetTime))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          challengeRef.doc(doc.id).update({
            'status': 'lose',
            'pointState': 'need',
            'checker': 'Wanna Do 관리자',
            'checkAt': doc.get('deadline'),
            'failReason': '마감시간 초과로 실패했어요.',
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }
}

class InitCalculateMyPointController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      getInternetDateTimeDio().then((internetTime) {
        initOnceCalculateMyPoint(internetTime);
      }).catchError((error) {
        print(error);
      });
    }
  }

  Future<DateTime> getInternetDateTimeDio() async {
    var dio = Dio();
    var url = 'https://worldtimeapi.org/api/timezone/Asia/Seoul';

    try {
      var response = await dio.get(url);
      String dateTime = response.data['datetime'];
      DateTime now = DateTime.parse(dateTime);
      return now.toLocal();
    } catch (e) {
      return DateTime.now();
    }
  }

  void initOnceCalculateMyPoint(DateTime internetTime) async {
    try {
      int totalCalculatePoint = 0;
      String authUid = FirebaseAuth.instance.currentUser!.uid;

      var checkupRecordRef = FirebaseFirestore.instance
          .collection('checkupRecord')
          .doc(authUid)
          .collection('checkupRecord');

      var challengeRef = FirebaseFirestore.instance
          .collection('challenge')
          .doc(authUid)
          .collection('challenge');

      QuerySnapshot checkupRecordSnapshot1 =
          await checkupRecordRef.where('pointState', isEqualTo: 'need').get();

      QuerySnapshot checkupRecordSnapshot2 = await checkupRecordRef
          .where('pointState', isEqualTo: 'wait')
          .where('createdAt',
              isLessThan:
                  Timestamp.fromDate(internetTime.subtract(Duration(days: 1))))
          .get();

      QuerySnapshot challengeSnapshot1 =
          await challengeRef.where('pointState', isEqualTo: 'need').get();

      QuerySnapshot challengeSnapshot2 = await challengeRef
          .where('pointState', isEqualTo: 'wait')
          .where('checkAt',
              isLessThan:
                  Timestamp.fromDate(internetTime.subtract(Duration(days: 1))))
          .get();

      FirebaseFirestore.instance
          .runTransaction((Transaction transaction) async {
        Future<void> calculateCheckupPoint(
            QuerySnapshot querySnapshot, String uid) async {
          try {
            for (var doc in querySnapshot.docs) {
              CheckupRecordModel data = CheckupRecordModel.fromJson(
                doc.data() as Map<String, dynamic>,
              );

              int calculatePoint = data.betPoint ~/ 4;
              totalCalculatePoint += calculatePoint;

              PointLogModel pointLogModel = PointLogModel(
                uid: uid,
                inout: 'in',
                pointFrom: 'checkup',
                point: calculatePoint,
                thatDocId: data.thatDocId,
              );

              DocumentReference pointLogRef = FirebaseFirestore.instance
                  .collection('point')
                  .doc(uid)
                  .collection('pointLog')
                  .doc();

              DocumentReference checkupRecordRef = FirebaseFirestore.instance
                  .collection('checkupRecord')
                  .doc(uid)
                  .collection('checkupRecord')
                  .doc(doc.id);

              transaction.set(pointLogRef, pointLogModel.toJson());
              transaction.update(checkupRecordRef, {'pointState': 'finish'});
            }
          } catch (e) {}
        }

        Future<void> calculateChallengePoint(
          QuerySnapshot querySnapshot,
          String uid,
        ) async {
          try {
            for (var doc in querySnapshot.docs) {
              ChallengeModel data = ChallengeModel.fromJson(
                doc.data() as Map<String, dynamic>,
              );

              int calculatePoint = data.betPoint ~/ 4;
              totalCalculatePoint += calculatePoint;

              DocumentReference pointLogRef = FirebaseFirestore.instance
                  .collection('point')
                  .doc(uid)
                  .collection('pointLog')
                  .doc();

              DocumentReference challengeRef = FirebaseFirestore.instance
                  .collection('challenge')
                  .doc(uid)
                  .collection('challenge')
                  .doc(doc.id);

              PointLogModel pointLogModel = PointLogModel(
                uid: uid,
                inout: 'in',
                pointFrom: 'challenge',
                point: calculatePoint,
                thatDocId: data.docId,
              );

              transaction.set(pointLogRef, pointLogModel.toJson());
              transaction.update(challengeRef, {'pointState': 'finish'});
            }
            DocumentReference statisticRef =
                FirebaseFirestore.instance.collection('statistic').doc(authUid);

            transaction.update(statisticRef, {
              'totalLose': FieldValue.increment(querySnapshot.docs.length),
              'monthLose': FieldValue.increment(querySnapshot.docs.length),
            });
          } catch (e) {}
        }

        if (checkupRecordSnapshot1.docs.isNotEmpty) {
          await calculateCheckupPoint(checkupRecordSnapshot1, authUid);
        }

        if (checkupRecordSnapshot2.docs.isNotEmpty) {
          await calculateCheckupPoint(checkupRecordSnapshot2, authUid);
        }

        if (challengeSnapshot1.docs.isNotEmpty) {
          await calculateChallengePoint(challengeSnapshot1, authUid);
        }

        if (challengeSnapshot2.docs.isNotEmpty) {
          await calculateChallengePoint(challengeSnapshot2, authUid);
        }

        if (checkupRecordSnapshot1.docs.isNotEmpty ||
            checkupRecordSnapshot2.docs.isNotEmpty ||
            challengeSnapshot1.docs.isNotEmpty ||
            challengeSnapshot2.docs.isNotEmpty) {
          DocumentReference pointRef =
              FirebaseFirestore.instance.collection('point').doc(authUid);

          transaction.update(pointRef, {
            'point': FieldValue.increment(totalCalculatePoint),
          });
        }
      });
    } catch (e) {}
  }
}
