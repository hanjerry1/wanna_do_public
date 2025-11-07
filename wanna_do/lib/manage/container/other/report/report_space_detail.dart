import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/space/space_post.dart';
import 'package:wanna_do/manage/container/user/user_manage.dart';
import 'package:wanna_do/model/report/report_model.dart';
import 'package:wanna_do/model/space/space_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';

class ReportSpaceDetail extends StatelessWidget {
  final DocumentSnapshot reportSpaceSnapshot;

  const ReportSpaceDetail({
    super.key,
    required this.reportSpaceSnapshot,
  });

  @override
  Widget build(BuildContext context) {
    ReportModel data = ReportModel.fromJson(
      reportSpaceSnapshot.data() as Map<String, dynamic>,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(
        title: data.chat != null ? '댓글 신고' : '게시글 신고',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '게시글 제목: ',
                              style: font17w700,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                data.title!,
                                style: font17w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              '게시글 내용: ',
                              style: font17w700,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                data.content!,
                                style: font17w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        if (data.chat != null)
                          Row(
                            children: [
                              Text(
                                '댓글 내용: ',
                                style: font17w700,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  data.chat!,
                                  style: font17w700,
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              '신고 이유: ',
                              style: font17w700,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                data.reportReason,
                                style: font17w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  SmallButtonFirst(
                    onPressed: () async {
                      QuerySnapshot spaceSnapshot = await FirebaseFirestore
                          .instance
                          .collection('space')
                          .where('docId', isEqualTo: data.postId)
                          .get();

                      if (spaceSnapshot.docs.isEmpty) {
                        ErrorGetxToast.show(context, '게시물이 없어요', '게시물이 사라졌어요');
                        return;
                      }

                      SpaceModel spaceData = SpaceModel.fromJson(
                        spaceSnapshot.docs.first.data() as Map<String, dynamic>,
                      );

                      Get.to(
                        () => SpacePost(
                          docId: spaceData.docId,
                          title: spaceData.title,
                          content: spaceData.content,
                          createdAt: spaceData.createdAt!.toDate(),
                          editAt: spaceData.editAt?.toDate(),
                          isUnknown: spaceData.isUnknown,
                          nickname: spaceData.nickname,
                          likeCount: spaceData.likeCount,
                          chatCount: spaceData.chatCount,
                          postUrl: spaceData.postUrl ?? [],
                          uid: spaceData.uid,
                          likeUids: spaceData.likeUids ?? [],
                          rank1Uid: '',
                          rank2Uid: '',
                          rank3Uid: '',
                        ),
                      );
                    },
                    backgroundColor: orangeColor,
                    content: Text(
                      '해당 게시물로 이동하기',
                      style: font15w700.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Column(
                    children: [
                      SmallButtonFirst(
                        onPressed: () {
                          Get.to(
                            () => UserManage(
                              uid: data.reporterUid,
                            ),
                          );
                        },
                        backgroundColor: mainColor,
                        content: Text(
                          '신고한사람 스페이스 경고하기',
                          style: font15w700.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SmallButtonFirst(
                        onPressed: () {
                          Get.to(
                            () => UserManage(
                              uid: data.reportedUid,
                            ),
                          );
                        },
                        backgroundColor: mainColor,
                        content: Text(
                          '신고당한사람 스페이스 경고하기',
                          style: font15w700.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: MediumButtonSecond(
                    buttonText: '신고 처리하기',
                    onPressed: () async {
                      try {
                        WriteBatch batch = FirebaseFirestore.instance.batch();

                        if (data.chat != null) {
                          DocumentReference chatRef = FirebaseFirestore.instance
                              .collection('space')
                              .doc(data.postId)
                              .collection('chat')
                              .doc(data.chatId);
                          batch.update(chatRef, {
                            'reportState': 'unable',
                          });

                          DocumentReference reportSpaceRef = FirebaseFirestore
                              .instance
                              .collection('report')
                              .doc('reportSpace')
                              .collection('reportSpace')
                              .doc(reportSpaceSnapshot.id);
                          batch.delete(reportSpaceRef);
                        } else {
                          DocumentReference spaceRef = FirebaseFirestore
                              .instance
                              .collection('space')
                              .doc(data.postId);
                          batch.update(spaceRef, {
                            'reportState': 'unable',
                          });

                          DocumentReference reportSpaceRef = FirebaseFirestore
                              .instance
                              .collection('report')
                              .doc('reportSpace')
                              .collection('reportSpace')
                              .doc(reportSpaceSnapshot.id);
                          batch.delete(reportSpaceRef);
                        }

                        await batch.commit();

                        Get.back();
                      } catch (e) {
                        ErrorGetxToast.show(
                            context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
                      }
                    },
                    backgroundColor: mainColorLight,
                    textColor: mainColor,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: MediumButtonSecond(
                    buttonText: '문제없는 게시물',
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('report')
                          .doc('reportSpace')
                          .collection('reportSpace')
                          .doc(reportSpaceSnapshot.id)
                          .delete();
                      Get.back();
                    },
                    backgroundColor: redColorLight,
                    textColor: redColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
