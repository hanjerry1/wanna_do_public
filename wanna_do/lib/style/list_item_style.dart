import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/challenge_detail/challenge_detail_certify.dart';
import 'package:wanna_do/container/challenge_detail/challenge_detail_result.dart';
import 'package:wanna_do/controller/timer_controller.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class MainListTimerItem extends StatelessWidget {
  final String category;
  final String goal;
  final DateTime deadline;
  final String status;
  final int betPoint;
  final String docId;
  final bool? isVideo;
  final bool? isVisible;
  final DateTime? certifyAt;
  final List<String>? certifyUrl;
  final String? thumbNailUrl;
  final DateTime? checkAt;
  final String? checker;
  final String? complainReason;
  final String? failReason;
  final TimerController controller;
  String reCheck = '';

  MainListTimerItem({
    Key? key,
    required this.category,
    required this.goal,
    required this.deadline,
    required this.status,
    required this.betPoint,
    required this.docId,
    this.certifyAt,
    this.certifyUrl,
    this.checkAt,
    this.checker,
    this.complainReason,
    this.failReason,
    this.isVideo,
    this.isVisible,
    this.thumbNailUrl,
  })  : controller = Get.put(TimerController(deadline, status, docId),
            tag: UniqueKey().toString()),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (status == 'lose' && complainReason != null ||
        status == 'win' && failReason != null) {
      reCheck = '재판정';
    }

    return Obx(
      () => GestureDetector(
        onTap: () {
          if (status == 'apply') {
            Get.to(
              () => ChallengeDetailCertify(
                goal: goal,
                category: category,
                deadline: deadline,
                status: status,
                betPoint: betPoint,
                docId: docId,
                certifyAt: certifyAt,
                certifyUrl: certifyUrl,
                checkAt: checkAt,
                checker: checker,
                complainReason: complainReason,
                failReason: failReason,
              ),
            );
          } else {
            Get.to(
              () => ChallengeDetailResult(
                goal: goal,
                category: category,
                deadline: deadline,
                status: status,
                betPoint: betPoint,
                docId: docId,
                isVideo: isVideo,
                isVisible: isVisible,
                certifyAt: certifyAt,
                certifyUrl: certifyUrl,
                thumbNailUrl: thumbNailUrl,
                checkAt: checkAt,
                checker: checker,
                complainReason: complainReason,
                failReason: failReason,
              ),
            );
          }
        },
        child: Container(
          color: Colors.white, // 터치영역을 확장하기 위해 컨테이너에 색상을 부여.
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    CategoryIconAssetUtils.getIcon(category),
                    fit: BoxFit.cover,
                  ),
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CategoryBackgroundColorUtils.getColor(category),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal,
                      style: font15w700,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 5),
                    Text(
                      controller.timeLeft.value,
                      style: font13w400,
                    ),
                  ],
                ),
              ),
              Text(
                reCheck,
                style: font12w400.copyWith(
                  color: charcoalColor.withOpacity(0.4),
                ),
              ),
              SizedBox(width: 10),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    challengeStatusTranslate(status),
                    style: font13w700.copyWith(
                      color: challengeStatusToTextColor(status),
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: challengeStatusToBackgroundColor(status),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainListTimeItem extends StatelessWidget {
  final String category;
  final String goal;
  final String status;
  final String time;
  final String docId;
  final int betPoint;
  final DateTime deadline;
  final bool? isVideo;
  final bool? isVisible;
  final String? thumbNailUrl;
  final String? checker;
  final String? complainReason;
  final String? failReason;
  final DateTime? certifyAt;
  final DateTime? checkAt;
  final List<String>? certifyUrl;
  String reCheck = '';

  MainListTimeItem({
    Key? key,
    required this.category,
    required this.goal,
    required this.status,
    required this.time,
    required this.docId,
    required this.betPoint,
    required this.deadline,
    this.isVideo,
    this.isVisible,
    this.thumbNailUrl,
    this.checker,
    this.complainReason,
    this.failReason,
    this.certifyAt,
    this.checkAt,
    this.certifyUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'lose' && complainReason != null ||
        status == 'win' && failReason != null) {
      reCheck = '재판정';
    }
    return GestureDetector(
      onTap: () {
        if (status == 'apply') {
          Get.to(
            () => ChallengeDetailCertify(
              goal: goal,
              category: category,
              deadline: deadline,
              status: status,
              betPoint: betPoint,
              docId: docId,
              certifyAt: certifyAt,
              certifyUrl: certifyUrl,
              checkAt: checkAt,
              checker: checker,
              complainReason: complainReason,
              failReason: failReason,
            ),
          );
        } else {
          Get.to(
            () => ChallengeDetailResult(
              goal: goal,
              category: category,
              deadline: deadline,
              status: status,
              betPoint: betPoint,
              docId: docId,
              isVideo: isVideo,
              isVisible: isVisible,
              certifyAt: certifyAt,
              certifyUrl: certifyUrl,
              thumbNailUrl: thumbNailUrl,
              checkAt: checkAt,
              checker: checker,
              complainReason: complainReason,
              failReason: failReason,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Container(
          color: Colors.white, // 터치영역을 확장하기 위해 컨테이너에 색상을 부여.
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    CategoryIconAssetUtils.getIcon(category),
                    fit: BoxFit.cover,
                  ),
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CategoryBackgroundColorUtils.getColor(category),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal,
                      style: font15w700,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 5),
                    Text(
                      time,
                      style: font13w400,
                    ),
                  ],
                ),
              ),
              Text(
                reCheck,
                style: font12w400.copyWith(
                  color: charcoalColor.withOpacity(0.4),
                ),
              ),
              SizedBox(width: 10),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    challengeStatusTranslate(status),
                    style: font13w700.copyWith(
                      color: challengeStatusToTextColor(status),
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: challengeStatusToBackgroundColor(status),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubListMonthWinItem extends StatelessWidget {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final String uid;
  final String name;
  final int rank;
  final int monthWin;
  final int monthLose;
  final int monthChallenge;
  final int monthScore;
  final int successRate;

  SubListMonthWinItem({
    super.key,
    required this.rank,
    required this.uid,
    required this.name,
    required this.monthWin,
    required this.monthLose,
    required this.monthScore,
    required this.monthChallenge,
  }) : successRate = (monthWin + monthLose) == 0
            ? 0
            : ((monthWin.toDouble() / (monthWin + monthLose)) * 100).toInt();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (monthWin < 30)
          Container(
            width: 50,
            child: Center(
              child: Text(
                '${rank}',
                style: font23w800,
              ),
            ),
          ),
        if (monthWin >= 30)
          Container(
            width: 50,
            child: Image.asset(
              'asset/img/rank_ticket.png',
              height: 40,
            ),
          ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authUid == uid ? '나' : '${name[0]}*${name.substring(2)} 님',
                style: font15w800.copyWith(
                  color: authUid == uid ? redColor : Colors.black,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '성공률 ${successRate}%',
                style: font14w400,
              ),
            ],
          ),
        ),
        Text(
          '${monthWin}',
          style: font20w700.copyWith(
            color: monthWin >= 30 ? mainColor : greyColorDark,
          ),
        ),
      ],
    );
  }
}

class SubListMonthScoreItem extends StatelessWidget {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final String uid;
  final String name;
  final int rank;
  final int monthWin;
  final int monthLose;
  final int monthChallenge;
  final int monthScore;
  final int successRate;

  SubListMonthScoreItem({
    super.key,
    required this.rank,
    required this.uid,
    required this.name,
    required this.monthWin,
    required this.monthLose,
    required this.monthScore,
    required this.monthChallenge,
  }) : successRate = (monthWin + monthLose) == 0
            ? 0
            : ((monthWin.toDouble() / (monthWin + monthLose)) * 100).toInt();

  String medalAsset(int rank) {
    switch (rank) {
      case 1:
        return 'asset/img/medal_first.png';
      case 2:
        return 'asset/img/medal_second.png';
      case 3:
        return 'asset/img/medal_third.png';
      default:
        return 'asset/img/medal_first.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (rank > 3)
          Container(
            width: 50,
            child: Center(
              child: Text(
                '${rank}',
                style: font23w800,
              ),
            ),
          ),
        if (rank <= 3)
          Container(
            width: 50,
            child: Image.asset(
              medalAsset(rank),
              height: 40,
            ),
          ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authUid == uid ? '나' : '${name[0]}*${name.substring(2)} 님',
                style: font15w800.copyWith(
                  color: authUid == uid ? redColor : Colors.black,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '성공률 ${successRate}%',
                style: font14w400,
              ),
            ],
          ),
        ),
        Text(
          '${monthScore} 점',
          style: font18w700.copyWith(
            color: mainColor,
          ),
        ),
      ],
    );
  }
}
