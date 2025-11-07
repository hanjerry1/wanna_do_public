import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/model/user/direct_message_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/dialog_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';
import 'package:webview_flutter/webview_flutter.dart';

final homeUrl1 = Uri.parse(
    'https://marvelous-cantaloupe-01b.notion.site/Wanna-Do-4790583d4943410fa14bcb80f619a877?pvs=4');

class NoticeHome extends StatefulWidget {
  const NoticeHome({super.key});

  @override
  State<NoticeHome> createState() => _NoticeHomeState();
}

class _NoticeHomeState extends State<NoticeHome> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final String? authName =
      FirebaseAuth.instance.currentUser!.displayName ?? '회원';
  WebViewController controller1 = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(homeUrl1);
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: SubAppBar(),
          body: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: '공지'),
                  Tab(text: '내소식'),
                ],
                labelColor: charcoalColor,
                labelStyle: font18w800.copyWith(fontFamily: 'NanumSquare'),
                unselectedLabelColor: charcoalColor.withOpacity(0.3),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 2,
                    color: charcoalColor,
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Stack(
                      children: [
                        WebViewWidget(
                          controller: controller1,
                        ),
                        if (isLoading)
                          Positioned.fill(
                            child: Container(
                              color: Colors.white,
                              child: Center(
                                child: Lottie.asset(
                                  'asset/lottie/short_loading_first_animation.json',
                                  height: 100,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('user')
                              .doc(authUid)
                              .collection('directMessage')
                              .orderBy('createdAt', descending: true)
                              .limit(20)
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: Lottie.asset(
                                  'asset/lottie/short_loading_first_animation.json',
                                  height: 100,
                                ),
                              );
                            }

                            if (snapshot.data!.docs.isEmpty) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                height: 300,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Lottie.asset(
                                        'asset/lottie/wanna_do_checker_animation.json',
                                        height: 200,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        '전달 사항이 있으면 알려드릴게요!',
                                        style: font15w400,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            List<DocumentSnapshot> docTotalList = [];

                            for (var doc in snapshot.data!.docs) {
                              docTotalList.add(doc);
                            }

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListView.separated(
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  DocumentSnapshot documentSnapshot =
                                      docTotalList[index];

                                  DirectMessageModel data =
                                      DirectMessageModel.fromJson(
                                    documentSnapshot.data()
                                        as Map<String, dynamic>,
                                  );

                                  return GestureDetector(
                                    onTap: () {
                                      Get.dialog(
                                        DialogTwoButton(
                                          title: '🔥 ${data.title}',
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '안녕하세요 $authName님!',
                                                style: font15w700,
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                data.content,
                                                style: font15w700,
                                              ),
                                            ],
                                          ),
                                          leftText: '취소',
                                          rightText: '확인하고 닫기',
                                          onLeftButtonPressed: () {
                                            Get.back();
                                          },
                                          onRightButtonPressed: () {
                                            Get.back();
                                          },
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0),
                                      child: Container(
                                        color: Colors.white,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SvgPicture.asset(
                                              'asset/svg/notice_check.svg',
                                              color: mainColor,
                                              height: 20,
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data.title,
                                                    style: font14w400.copyWith(
                                                      color: charcoalColor,
                                                    ),
                                                  ),
                                                  SizedBox(height: 7),
                                                  Text(
                                                    data.content,
                                                    style: font14w700.copyWith(
                                                      color: charcoalColor,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  DateFormatUtilsSixth
                                                      .formatDay(
                                                    data.createdAt!.toDate(),
                                                  ),
                                                  style: font13w400.copyWith(
                                                    color: charcoalColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return Divider(
                                    thickness: 0.3,
                                  );
                                },
                                itemCount: docTotalList.length,
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
