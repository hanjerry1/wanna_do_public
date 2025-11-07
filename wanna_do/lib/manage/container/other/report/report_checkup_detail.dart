import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanna_do/manage/container/user/user_manage.dart';
import 'package:wanna_do/model/challenge/challenge_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/public/video_play.dart';
import 'package:wanna_do/container/public/image_viewer.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ReportCheckupDetail extends StatefulWidget {
  final String reportReason;
  final String docId;
  final String reportDocId;
  final String reportedUid;
  final String reporterUid;

  ReportCheckupDetail({
    super.key,
    required this.docId,
    required this.reportDocId,
    required this.reportReason,
    required this.reportedUid,
    required this.reporterUid,
  });

  @override
  State<ReportCheckupDetail> createState() => _ReportCheckupDetailState();
}

class _ReportCheckupDetailState extends State<ReportCheckupDetail> {
  DocumentSnapshot? documentSnapshot1;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('checkup')
        .where('docId', isEqualTo: widget.docId)
        .get();

    String checkupDocId = querySnapshot.docs.first.id;

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('checkup')
        .doc(checkupDocId)
        .get();
    setState(() {
      documentSnapshot1 = documentSnapshot;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (documentSnapshot1 == null) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Lottie.asset(
            'asset/lottie/short_loading_first_animation.json',
            height: 100,
          ),
        ),
      );
    }
    ChallengeModel data = ChallengeModel.fromJson(
      documentSnapshot1!.data() as Map<String, dynamic>,
    );

    double mainAxisSpacing = 10;
    double gridViewWidth = MediaQuery.of(context).size.width;
    double itemWidth = (gridViewWidth - 2 * 10) / 3;
    double gridViewHeight =
        (itemWidth + mainAxisSpacing) * (data.certifyUrl!.length / 3).ceil() -
            mainAxisSpacing;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: [
                                Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data.category,
                                              style: font15w700,
                                            ),
                                            SizedBox(height: 7),
                                            Text(
                                              DateFormatUtilsSecond.formatDay(
                                                data.certifyAt!.toDate(),
                                              ),
                                              style: font13w400,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${data.betPoint} 원',
                                        style: font15w700.copyWith(
                                          color: mainColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    CategoryIconAssetUtils.getIcon(
                                      data.category,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CategoryBackgroundColorUtils.getColor(
                                      data.category),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  data.goal,
                                  style: font15w700.copyWith(height: 1.5),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 25),
                          Container(
                            decoration: BoxDecoration(
                              color: greyColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '신고이유',
                                    style: font15w800.copyWith(
                                      color: mainColor,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      widget.reportReason,
                                      style: font13w400.copyWith(
                                        color: Colors.black.withOpacity(0.8),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 10,
                      color: greyColor.withOpacity(0.3),
                    ),
                    SizedBox(height: 25),
                    if (data.isVideo!)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '인증 내역',
                              style: font23w800,
                            ),
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => VideoPlay(
                                      videoUrl: data.certifyUrl!.first,
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    color: Colors.black,
                                    child: AspectRatio(
                                      aspectRatio: 4 / 3,
                                      child: CachedNetworkImage(
                                        imageUrl: data.thumbNailUrl!,
                                        placeholder: (context, url) => Center(
                                          child: Lottie.asset(
                                            'asset/lottie/short_loading_first_animation.json',
                                            height: 100,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 30),
                                                child: Text(
                                                  '30일 저장기간이 지나 영상을 볼 수 없어요',
                                                  style: font15w400.copyWith(
                                                    color: orangeColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Icon(
                                      Icons.play_circle_outline_rounded,
                                      size: 120,
                                      color: Colors.black.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    if (!data.isVideo!)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '인증 내역',
                              style: font23w800,
                            ),
                            SizedBox(height: 20),
                            Container(
                              height: gridViewHeight,
                              child: ScrollConfiguration(
                                behavior: NoGlowScrollBehavior(),
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: mainAxisSpacing,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ImageViewer(
                                              imageList: data.certifyUrl!,
                                              initialIndex: index,
                                            ),
                                          ),
                                        );
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl: data.certifyUrl![index],
                                        placeholder: (context, url) => Center(
                                          child: Lottie.asset(
                                            'asset/lottie/short_loading_first_animation.json',
                                            height: 80,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  },
                                  itemCount: data.certifyUrl!.length,
                                  physics: NeverScrollableScrollPhysics(),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    Column(
                      children: [
                        SmallButtonFirst(
                          onPressed: () {
                            Get.to(
                              () => UserManage(
                                uid: widget.reporterUid,
                              ),
                            );
                          },
                          backgroundColor: mainColor,
                          content: Text(
                            '신고한사람 체크업 경고하기',
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
                                uid: widget.reportedUid,
                              ),
                            );
                          },
                          backgroundColor: mainColor,
                          content: Text(
                            '신고당한사람 체크업 경고하기',
                            style: font15w700.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                ),
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
                        QuerySnapshot querySnapshot = await FirebaseFirestore
                            .instance
                            .collection('checkup')
                            .where('docId', isEqualTo: data.docId)
                            .get();

                        if (querySnapshot.docs.isEmpty) {
                          ErrorGetxToast.show(
                              context, '문서가 없어요', '문서가 존재하지 않아요');
                          Get.back();
                          return;
                        }

                        String checkupDocId = querySnapshot.docs.first.id;

                        WriteBatch batch = FirebaseFirestore.instance.batch();

                        DocumentReference checkupRef = FirebaseFirestore
                            .instance
                            .collection('checkup')
                            .doc(checkupDocId);
                        batch.update(checkupRef, {'reportState': 'unable'});

                        DocumentReference reportRef = FirebaseFirestore.instance
                            .collection('report')
                            .doc('reportCheckup')
                            .collection('reportCheckup')
                            .doc(widget.reportDocId);
                        batch.delete(reportRef);

                        await batch.commit();

                        Get.back();
                      } catch (e) {}
                    },
                    backgroundColor: mainColorLight,
                    textColor: mainColor,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: MediumButtonSecond(
                    buttonText: '문제없음',
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('report')
                          .doc('reportCheckup')
                          .collection('reportCheckup')
                          .doc(widget.reportDocId)
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
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
