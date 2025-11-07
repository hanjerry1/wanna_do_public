import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/manage/container/other/rank/rank_manage.dart';
import 'package:wanna_do/manage/container/other/report/contact_manage.dart';
import 'package:wanna_do/manage/container/other/report/report_checkup_manage.dart';
import 'package:wanna_do/manage/container/other/report/report_space_manage.dart';
import 'package:wanna_do/style/text_style.dart';

class ManageMainFourth extends StatefulWidget {
  const ManageMainFourth({super.key});

  @override
  State<ManageMainFourth> createState() => _ManageMainFourthState();
}

class _ManageMainFourthState extends State<ManageMainFourth>
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
              Get.to(() => ReportCheckupManage());
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
                        '체크업 신고 관리하기',
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
              Get.to(() => ReportSpaceManage());
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
                        '스페이스 신고 관리하기',
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
              Get.to(() => ContactManage());
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
                        '의견 및 문의사항 관리하기',
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
              Get.to(() => RankManage());
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
                        '명예의 전당 관리하기',
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
