import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/checkup/checkup_check.dart';
import 'package:wanna_do/container/checkup/checkup_first_guide.dart';
import 'package:wanna_do/container/checkup/checkup_my.dart';
import 'package:wanna_do/container/help/contact_home.dart';
import 'package:wanna_do/container/help/report_home.dart';
import 'package:wanna_do/model/challenge/challenge_model.dart';
import 'package:wanna_do/model/checkup/request_queue_model.dart';
import 'package:wanna_do/model/statistic/statistic_model.dart';
import 'package:wanna_do/model/user/user_state_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class MainCheckup extends StatefulWidget {
  const MainCheckup({super.key});

  @override
  State<MainCheckup> createState() => _MainCheckupState();
}

class _MainCheckupState extends State<MainCheckup> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final ScrollController scrollController = ScrollController();
  List<DocumentSnapshot> docFutureList = [];
  DocumentSnapshot? lastDocument;
  DateTime? lastRefreshTime;
  bool isFirst = false;
  bool isUnable = false;
  bool isMoreLoading = false;
  bool isLoading = false;
  bool hasMoreData = true;
  int todayCheckup = 0;
  int totalCheckup = 0;
  int totalLoadedDataCount = 0;

  @override
  void initState() {
    super.initState();
    getUserStateCheckup();
    loadInitData();
    scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollListener() async {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isMoreLoading &&
        hasMoreData) {
      await loadMoreData();
    }
  }

  Future<void> onRefresh() async {
    final now = DateTime.now();
    if (lastRefreshTime == null ||
        now.difference(lastRefreshTime!).inSeconds > 5) {
      lastRefreshTime = now;
      setState(() {
        docFutureList = [];
        hasMoreData = true;
        isLoading = true;
      });
      await loadInitData();
    } else {
      final secondsLeft = 5 - now.difference(lastRefreshTime!).inSeconds;
      ErrorGetxToast.show(
        context,
        '새로고침 대기',
        '$secondsLeft초 후에 다시 새로고침 해주세요',
      );
    }
  }

  Future<void> getUserStateCheckup() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(authUid)
        .collection('userState')
        .doc(authUid)
        .get();

    UserStateModel data = UserStateModel.fromJson(
      documentSnapshot.data() as Map<String, dynamic>,
    );

    if (documentSnapshot.exists && data.checkupState == '3') {
      setState(() {
        isUnable = true;
      });
    }
  }

  Future<void> loadInitData() async {
    try {
      docFutureList = [];
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('checkup')
          .where('isVisible', isEqualTo: true)
          .where('reportState', isEqualTo: 'able')
          .where('status', isEqualTo: 'certify')
          .where('checkingState', isEqualTo: 'none')
          .orderBy('certifyAt', descending: false)
          .limit(4)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          docFutureList.add(doc);
        }
        setState(() {
          lastDocument = docFutureList.last;
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {}
  }

  Future<void> loadMoreData() async {
    try {
      if (isMoreLoading || totalLoadedDataCount >= 200) return;
      setState(() {
        isMoreLoading = true;
      });
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('checkup')
          .where('isVisible', isEqualTo: true)
          .where('reportState', isEqualTo: 'able')
          .where('status', isEqualTo: 'certify')
          .where('checkingState', isEqualTo: 'none')
          .orderBy('certifyAt', descending: false)
          .startAfterDocument(lastDocument!)
          .limit(2)
          .get();

      List<DocumentSnapshot> newDocuments = querySnapshot.docs;
      if (newDocuments.isEmpty) {
        hasMoreData = false;
      } else {
        lastDocument = newDocuments.last;
        docFutureList.addAll(newDocuments);
        totalLoadedDataCount += newDocuments.length;
      }
      setState(() {
        isMoreLoading = false;
      });
    } catch (e) {}
  }

  Future<void> checkChallenge(ChallengeModel challengeData) async {
    try {
      setState(() {
        isLoading = true;
      });

      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          isLoading = false;
        });
        ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
        return;
      }

      if (todayCheckup <= 0) {
        setState(() {
          isLoading = false;
        });
        ErrorGetxToast.show(
            context, '검사는 하루에 10번까지 가능해요', '내일이 되면 다시 이용할 수 있어요');
        return;
      }

      String deviceId = '';
      QuerySnapshot checkupSnapshot = await FirebaseFirestore.instance
          .collection('checkup')
          .where('docId', isEqualTo: challengeData.docId)
          .get();

      if (checkupSnapshot.docs.isEmpty) {
        setState(() {
          docFutureList = [];
          hasMoreData = true;
          isLoading = false;
        });
        await loadInitData();
        ErrorGetxToast.show(context, '이미 처리된 챌린지에요', '다른 챌린지를 검사해주세요');
        return;
      }

      DocumentSnapshot checkupDoc = checkupSnapshot.docs.first;
      DocumentReference docRef = checkupDoc.reference;

      if (checkupDoc.get('checkingState') == 'checking') {
        setState(() {
          docFutureList = [];
          hasMoreData = true;
          isLoading = false;
        });
        await loadInitData();
        ErrorGetxToast.show(context, '이미 검사중인 챌린지에요', '다른 챌린지를 검사해주세요');
        return;
      }

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
        deviceId = iosInfo.identifierForVendor!;
      }

      RequestQueueModel requestQueueModel = RequestQueueModel(
        uid: authUid,
        deviceInfo: deviceId,
      );

      await docRef.collection('requestQueue').add(requestQueueModel.toJson());

      QuerySnapshot requestQueueSnapshot = await docRef
          .collection('requestQueue')
          .orderBy('createdAt', descending: false)
          .limit(1)
          .get();

      if (requestQueueSnapshot.docs.isEmpty) {
        setState(() {
          docFutureList = [];
          hasMoreData = true;
          isLoading = false;
        });
        await loadInitData();
        ErrorGetxToast.show(context, '이미 검사중인 챌린지에요', '다른 챌린지를 검사해주세요');
        return;
      }

      DocumentSnapshot requestQueueDoc = requestQueueSnapshot.docs.first;

      RequestQueueModel requestQueueData = RequestQueueModel.fromJson(
        requestQueueDoc.data() as Map<String, dynamic>,
      );

      if (requestQueueData.uid == authUid &&
          requestQueueData.deviceInfo == deviceId) {
        await docRef.update({
          'checkingState': 'checking',
        });
        await FirebaseFirestore.instance
            .collection('statistic')
            .doc(authUid)
            .update({
          'todayCheckup': FieldValue.increment(-1),
        });

        Get.off(
          () => CheckupCheck(
            uid: challengeData.uid,
            goal: challengeData.goal,
            category: challengeData.category,
            betPoint: challengeData.betPoint,
            deadline: challengeData.deadline.toDate(),
            docId: challengeData.docId,
            reciptId: challengeData.receiptId,
            isVideo: challengeData.isVideo!,
            certifyAt: challengeData.certifyAt!.toDate(),
            certifyUrl: challengeData.certifyUrl!,
            thumbNailUrl: challengeData.thumbNailUrl!,
          ),
        );
      } else {
        setState(() {
          docFutureList = [];
          hasMoreData = true;
          isLoading = false;
        });
        await loadInitData();
        ErrorGetxToast.show(context, '이미 검사중인 챌린지에요', '다른 챌린지를 검사해주세요');
        return;
      }
    } catch (e) {
      setState(() {
        docFutureList = [];
        hasMoreData = true;
        isLoading = false;
      });
      await loadInitData();
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MainAppBar(
        title: '체크업',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: mainColorLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('statistic')
                          .doc(authUid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Center(
                            child: Lottie.asset(
                              'asset/lottie/short_loading_first_animation.json',
                              height: 10,
                            ),
                          );
                        }

                        StatisticModel data = StatisticModel.fromJson(
                          snapshot.data!.data() as Map<String, dynamic>,
                        );

                        todayCheckup = data.todayCheckup;
                        if (data.totalCheckup == 0) {
                          isFirst = true;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Text(
                            '오늘 검사기회: ${data.todayCheckup}번',
                            style: font15w700.copyWith(
                              color: mainColor,
                            ),
                          ),
                        );
                      }),
                ),
                IconButton(
                  onPressed: () {
                    Get.to(() => CheckupMy());
                  },
                  icon: SvgPicture.asset(
                    'asset/svg/checkup_profile.svg',
                    height: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
        textStyle: font25w800.copyWith(
          color: Colors.black,
        ),
      ),
      body: Stack(
        children: [
          CustomMaterialIndicator(
            elevation: 0,
            backgroundColor: Colors.white,
            onRefresh: onRefresh,
            indicatorBuilder: (context, controller) {
              return Lottie.asset(
                'asset/lottie/short_loading_first_animation.json',
                height: 100,
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isLoading && docFutureList.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'asset/lottie/wanna_do_checker_animation.json',
                          height: 200,
                        ),
                        Text(
                          '아직 체크업에 올라온 챌린지가 없어요',
                          style: font15w400,
                        ),
                        SizedBox(height: 30),
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              docFutureList = [];
                              hasMoreData = true;
                              isLoading = true;
                            });
                            await loadInitData();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 25,
                                color: mainColor,
                              ),
                              SizedBox(width: 5),
                              Text(
                                '새로고침',
                                style: font15w800.copyWith(
                                  color: mainColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (docFutureList.isNotEmpty)
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: NoGlowScrollBehavior(),
                      child: ListView.builder(
                        controller: scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot checkupSnapshot =
                              docFutureList[index];

                          ChallengeModel data = ChallengeModel.fromJson(
                            checkupSnapshot.data() as Map<String, dynamic>,
                          );

                          return Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 65,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                    vertical: 4.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 10),
                                      Container(
                                        width: 55,
                                        height: 55,
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
                                          color: CategoryBackgroundColorUtils
                                              .getColor(data.category),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data.goal,
                                              style: font15w700,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              DateFormatUtilsSecond.formatDay(
                                                  data.certifyAt!.toDate()),
                                              style: font13w400,
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton(
                                        icon: Icon(
                                          Icons.more_vert_rounded,
                                          color: Colors.black,
                                        ),
                                        itemBuilder: (BuildContext context) => [
                                          PopupMenuItem(
                                            value: 'report',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.error_outline,
                                                  color: Colors.black
                                                      .withOpacity(0.6),
                                                  size: 23,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  '신고하기',
                                                  style: font16w700.copyWith(
                                                    color: Colors.black
                                                        .withOpacity(0.6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onSelected: (String result) {
                                          if (result == 'report') {
                                            Get.to(
                                              () => ReportHome(
                                                goal: data.goal,
                                                category: data.category,
                                                deadline:
                                                    data.deadline.toDate(),
                                                status: data.status,
                                                betPoint: data.betPoint,
                                                docId: data.docId,
                                                uid: data.uid,
                                                isVideo: data.isVideo,
                                                isVisible: data.isVisible,
                                                certifyAt:
                                                    data.certifyAt!.toDate(),
                                                applyAt: data.applyAt!.toDate(),
                                                certifyUrl: data.certifyUrl,
                                                thumbNailUrl: data.thumbNailUrl,
                                              ),
                                            );
                                          }
                                        },
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        elevation: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.width / 1.77,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 16 / 9,
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
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.error_outline_rounded,
                                                size: 25,
                                                color: orangeColor,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                '저장기간 경과',
                                                style: font15w700.copyWith(
                                                  color: orangeColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16.0),
                                        child: SmallButtonFirst(
                                          onPressed: () async {
                                            if (isFirst) {
                                              final result = await Get.to(
                                                  () => CheckupFirstGuide());
                                              if (result != null) {
                                                isFirst = result;
                                              }
                                            } else if (data.uid == authUid) {
                                              ErrorGetxToast.show(
                                                  context,
                                                  '내 챌린지는 검사할 수 없어요',
                                                  '다른 챌린지를 검사해주세요');
                                            } else {
                                              await checkChallenge(data);
                                            }
                                          },
                                          backgroundColor:
                                              mainColor.withOpacity(0.9),
                                          content: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(width: 5),
                                              Text(
                                                '검사해주기',
                                                style: font16w700.copyWith(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        itemCount: docFutureList.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isLoading) ShortLoadingFirst(),
          if (isUnable)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '체크업 이용 제한 안내',
                              style: font18w800,
                            ),
                            SizedBox(height: 10),
                            Text(
                              '체크업에서 3번 이상의 부정확한 판정이 확인되어 체크업을 이용할 수 없어요. 다시 이용을 원할 경우 고객센터로 직접 문의해주세요.',
                              style: font15w400.copyWith(
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => ContactHome());
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '문의하기',
                                    style: font16w800.copyWith(
                                      color: mainColor,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
