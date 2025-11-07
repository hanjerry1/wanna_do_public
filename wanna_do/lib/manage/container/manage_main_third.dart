import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/manage/container/point/point_detail.dart';
import 'package:wanna_do/model/point/point_out_model.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ManageMainThird extends StatefulWidget {
  const ManageMainThird({super.key});

  @override
  State<ManageMainThird> createState() => _ManageMainThirdState();
}

class _ManageMainThirdState extends State<ManageMainThird>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
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
                    .collection('service')
                    .doc('pointOut')
                    .collection('pointOut')
                    .where('isFinish', isEqualTo: false)
                    .orderBy('createdAt', descending: false)
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
                      DocumentSnapshot pointOutSnapshot = docFutureList[index];

                      PointOutModel data = PointOutModel.fromJson(
                        pointOutSnapshot.data() as Map<String, dynamic>,
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(
                              () => PointDetail(
                                challengeSnapshot: pointOutSnapshot,
                                docId: pointOutSnapshot.id,
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '출금요청금액: ${data.point}',
                                            style: font16w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'name: ${data.name}',
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'uid: ${data.uid}',
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                              '요청일: ${data.createdAt!.toDate().toString()}'),
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
    );
  }
}
