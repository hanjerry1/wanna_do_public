import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/manage/container/other/report/contact_detail.dart';
import 'package:wanna_do/model/service/contact_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ContactManage extends StatefulWidget {
  const ContactManage({super.key});

  @override
  State<ContactManage> createState() => _ContactManageState();
}

class _ContactManageState extends State<ContactManage> {
  int selectedButtonIndex = 0;
  final List<String> buttonStatusTexts = [
    '미확인 문의',
    '확인 문의',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Wrap(
              spacing: 5,
              runSpacing: 5,
              children: List.generate(2, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedButtonIndex = index;
                    });
                  },
                  child: StateButtonFirst(
                    widgetText: buttonStatusTexts[index],
                    isSelected: selectedButtonIndex == index,
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 10),
          if (selectedButtonIndex == 0)
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
                        .doc('contact')
                        .collection('contact')
                        .where('status', isEqualTo: 'none')
                        .orderBy('createdAt', descending: false)
                        .limit(20)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
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

                      List<DocumentSnapshot> docTotalList = [];

                      for (var doc in snapshot.data!.docs) {
                        docTotalList.add(doc);
                      }

                      return ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot contactSnapshot =
                              docTotalList[index];

                          ContactModel data = ContactModel.fromJson(
                            contactSnapshot.data() as Map<String, dynamic>,
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: GestureDetector(
                              onTap: () async {
                                Get.to(
                                  () => ContactDetail(
                                    contactSnapshot: contactSnapshot,
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
                                            .doc('contact')
                                            .collection('contact')
                                            .doc(contactSnapshot.id)
                                            .update({'status': 'checked'});
                                        setState(() {});
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: redColorLight,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.check,
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
                                                  '문의내용: ${data.content}',
                                                  style: font16w700,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                  '문의자: ${data.uid}',
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                    '문의일: ${data.createdAt!.toDate().toString()}'),
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
                        itemCount: docTotalList.length,
                      );
                    },
                  ),
                ),
              ),
            ),
          if (selectedButtonIndex == 1)
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
                        .doc('contact')
                        .collection('contact')
                        .where('status', isEqualTo: 'checked')
                        .orderBy('createdAt', descending: true)
                        .limit(20)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
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

                      List<DocumentSnapshot> docTotalList = [];

                      for (var doc in snapshot.data!.docs) {
                        docTotalList.add(doc);
                      }

                      return ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot contactSnapshot =
                              docTotalList[index];

                          ContactModel data = ContactModel.fromJson(
                            contactSnapshot.data() as Map<String, dynamic>,
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: GestureDetector(
                              onTap: () async {
                                Get.to(
                                  () => ContactDetail(
                                    contactSnapshot: contactSnapshot,
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
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  data.content,
                                                  style: font16w700,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                  '문의자: ${data.uid}',
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                    '문의일: ${data.createdAt!.toDate().toString()}'),
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
                        itemCount: docTotalList.length,
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
