import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/manage/container/challenge/challenge_checkup_manage.dart';
import 'package:wanna_do/manage/container/challenge/challenge_complain_manage.dart';
import 'package:wanna_do/manage/container/challenge/challenge_judge_manage.dart';
import 'package:wanna_do/style/text_style.dart';

class ManageMainFirst extends StatefulWidget {
  const ManageMainFirst({super.key});

  @override
  State<ManageMainFirst> createState() => _ManageMainFirstState();
}

class _ManageMainFirstState extends State<ManageMainFirst>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => ChallengeJudgeManage());
            },
            child: Container(
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '챌린지 판정 관리하기',
                        style: font20w700,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              Get.to(() => ChallengeComplainManage());
            },
            child: Container(
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '챌린지 이의제기 관리하기',
                        style: font20w700,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              Get.to(() => ChallengeCheckupManage());
            },
            child: Container(
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '모든 체크업 감시하기',
                        style: font20w700,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
