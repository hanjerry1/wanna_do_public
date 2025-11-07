import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class TimerController extends GetxController {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  RxString timeLeft = ''.obs;
  late final DateTime deadline;
  late Timer timer;
  String status;
  String docId;

  TimerController(this.deadline, this.status, this.docId) {
    timeLeft.value = getTimeLeft(deadline);
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      timeLeft.value = getTimeLeft(deadline);
    });
  }

  @override
  void onClose() {
    timer.cancel();
    super.onClose();
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

  String getTimeLeft(DateTime deadline) {
    Duration difference = deadline.difference(DateTime.now());

    if (status != 'apply') {
      return '인증 마감';
    }
    if (status == 'apply' && difference.isNegative) {
      getInternetDateTimeDio().then((internetTime) async {
        if (status == 'apply' && internetTime.isAfter(deadline)) {
          try {
            await FirebaseFirestore.instance
                .collection('challenge')
                .doc(authUid)
                .collection('challenge')
                .doc(docId)
                .update({
              'status': 'lose',
              'pointState': 'need',
              'checker': 'Wanna Do 관리자',
              'checkAt': Timestamp.fromDate(deadline),
              'failReason': '마감시간 초과로 실패했어요.',
            });
            status = 'lose';
          } catch (e) {}
        }
      }).catchError((error) {
        print(error);
      });

      return '인증 마감';
    }
    int days = difference.inDays;
    int hours = difference.inHours.remainder(24);
    int minutes = difference.inMinutes.remainder(60);
    int seconds = difference.inSeconds.remainder(60);

    if (days == 0 && hours == 0 && minutes == 0) {
      return '${seconds}초 남음';
    } else if (days == 0 && hours == 0) {
      return '${minutes}분 ${seconds}초 남음';
    } else if (days == 0) {
      return '${hours}시간 ${minutes}분 ${seconds}초 남음';
    }
    return '${days}일 ${hours}시간 ${minutes}분 ${seconds}초 남음';
  }
}
