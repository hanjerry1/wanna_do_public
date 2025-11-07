import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/manage/container/other/report/report_space_detail.dart';
import 'package:wanna_do/model/report/report_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ReportSpaceManage extends StatefulWidget {
  const ReportSpaceManage({super.key});

  @override
  State<ReportSpaceManage> createState() => _ReportSpaceManageState();
}

class _ReportSpaceManageState extends State<ReportSpaceManage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(),
      body: Column(
        children: [
          Expanded(
            child: CustomMaterialIndicator(
              elevation: 0,
              backgroundColor: Colors.white,
              onRefresh: () async {
                setState(() {});
              },
              indicatorBuilder: (context, controller) {
                return Lottie.asset(
                  'asset/lottie/short_loading_first_animation.json',
                  height: 100,
                );
              },
              child: ScrollConfiguration(
                behavior: NoGlowScrollBehavior(),
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('report')
                      .doc('reportSpace')
                      .collection('reportSpace')
                      .orderBy('createdAt', descending: false)
                      .limit(10)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        height: 300,
                        child: Center(
                          child: Lottie.asset(
                            'asset/lottie/short_loading_first_animation.json',
                            height: 100,
                          ),
                        ),
                      );
                    }

                    List<DocumentSnapshot> docTotalList = [];
                    List<DocumentSnapshot> docFutureList = [];
                    for (var doc in snapshot.data!.docs) {
                      docTotalList.add(doc);
                    }
                    docFutureList = docTotalList;

                    return ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot reportSpaceSnapshot =
                            docFutureList[index];

                        ReportModel data = ReportModel.fromJson(
                          reportSpaceSnapshot.data() as Map<String, dynamic>,
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: GestureDetector(
                            onTap: () async {
                              Get.to(
                                () => ReportSpaceDetail(
                                  reportSpaceSnapshot: reportSpaceSnapshot,
                                ),
                              )!
                                  .then((_) {
                                setState(() {});
                              });
                            },
                            child: Container(
                              color: Colors.white,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await FirebaseFirestore.instance
                                          .collection('report')
                                          .doc('reportSpace')
                                          .collection('reportSpace')
                                          .doc(reportSpaceSnapshot.id)
                                          .delete();
                                      setState(() {});
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: redColorLight,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.close_outlined,
                                          color: redColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                data.chat != null
                                                    ? '댓글 신고이유: ${data.reportReason}'
                                                    : '게시글 신고이유: ${data.reportReason}',
                                                style: font16w700,
                                                maxLines: 3,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                data.chat != null
                                                    ? '댓글 내용: ${data.chat}'
                                                    : '게시글 내용: ${data.content}',
                                                style: font15w400,
                                                maxLines: 3,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '신고한사람: ${data.reporterUid}',
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                  '신고일: ${data.createdAt!.toDate().toString()}'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.chevron_right_outlined,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider();
                      },
                      itemCount: docFutureList.length,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
