import 'dart:convert';
import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart' as boot;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_tooltip/easy_tooltip.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/challenge/challenge_end.dart';
import 'package:wanna_do/container/help/agreement_home.dart';
import 'package:wanna_do/container/help/role_home.dart';
import 'package:wanna_do/model/challenge/challenge_model.dart';
import 'package:wanna_do/model/user/user_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ChallengesOnlyPay extends StatefulWidget {
  const ChallengesOnlyPay({super.key});

  @override
  State<ChallengesOnlyPay> createState() => _ChallengesOnlyPayState();
}

class _ChallengesOnlyPayState extends State<ChallengesOnlyPay> {
  Payload payload = Payload();
  String androidApplicationId = dotenv.env['BOOTPAY_ANDROID_KEY'] ?? '';
  String iosApplicationId = dotenv.env['BOOTPAY_IOS_KEY'] ?? '';
  final authUid = FirebaseAuth.instance.currentUser!.uid;
  Future<List<Map<String, dynamic>>>? loadChallengeListFuture;
  late ScrollController scrollController = ScrollController();
  List<int> selectedCheckIndexs = [];
  final List<String> checkTexts = [
    '[필수] 이용약관 동의',
    '[필수] 개인정보 수집이용 동의',
    '[필수] 결제 및 환불 동의',
    '[선택] 이벤트 알림 동의',
  ];
  bool isClicked = false;
  bool isMaxScroll = false;
  bool isLoading = false;
  bool isFirst = false;
  bool isDone = false;

  @override
  void initState() {
    super.initState();
    getInternetDateTimeDio().then((internetTime) {
      bootpayRequestDataInit(internetTime);
    }).catchError((error) {
      print(error);
    });
    checkApplyFirst();
    loadChallengeListFuture = loadChallengeList();
    scrollController = ScrollController()
      ..addListener(() {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          setState(() {
            isMaxScroll = true;
          });
        } else {
          setState(() {
            isMaxScroll = false;
          });
        }
      });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollAnimateToPage() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<List<Map<String, dynamic>>> loadChallengeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int totalChallengeList = prefs.getInt('totalChallengeList') ?? 0;
    List<Map<String, dynamic>> allData = [];

    for (int i = 1; i <= totalChallengeList; i++) {
      String? jsonString = prefs.getString('ChallengeList$i');
      if (jsonString != null) {
        Map<String, dynamic> data = json.decode(jsonString);
        allData.add(data);
      }
    }
    return allData;
  }

  bootpayRequestDataInit(DateTime now) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('user').doc(authUid).get();

    UserModel userData = UserModel.fromJson(
      documentSnapshot.data() as Map<String, dynamic>,
    );

    List<Map<String, dynamic>> challengeList = await loadChallengeList();

    List<Item> itemList = [];
    double totalPrice = 0;

    for (var challengeData in challengeList) {
      Item item = Item();
      item.name = challengeData['category'];
      item.qty = 1;
      item.id = now.millisecondsSinceEpoch.toString();
      item.price = double.parse(challengeData['betPoint']);
      totalPrice += double.parse(challengeData['betPoint']);
      itemList.add(item);
    }

    payload.androidApplicationId = androidApplicationId;
    payload.iosApplicationId = iosApplicationId;
    payload.orderName = "챌린지 신청";
    payload.price = totalPrice;
    payload.orderId = authUid + now.millisecondsSinceEpoch.toString();
    payload.items = itemList;

    boot.User user = boot.User();
    user.username = userData.name;
    user.id = userData.uid;

    Extra extra = Extra();
    extra.appScheme = 'bootpayFlutterExample';
    extra.cardQuota = '0';
    payload.user = user;
    payload.extra = extra;
    payload.extra?.openType = "iframe";
  }

  Future<void> checkApplyFirst() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('challenge')
        .doc(authUid)
        .collection('challenge')
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      setState(() {
        isFirst = true;
      });
    }
  }

  Future<void> startBootpay(BuildContext context) async {
    Bootpay().requestPayment(
      context: context,
      payload: payload,
      showCloseButton: false,
      onCancel: (String data) {
        setState(() {
          isLoading = false;
          isClicked = false;
        });
      },
      onError: (String data) {
        setState(() {
          isLoading = false;
          isClicked = false;
        });
      },
      onClose: () {
        if (mounted && !isDone) {
          Bootpay().dismiss(context);
          setState(() {
            isLoading = false;
            isClicked = false;
          });
        }
      },
      onIssued: (String data) {},
      onConfirm: (String data) {
        return true;
      },
      onDone: (String data) {
        setState(() {
          isDone = true;
        });
        String receiptId = json.decode(data)['data']['receipt_id'];
        applyChallengesTran(receiptId);
      },
    );
  }

  Future<void> applyChallengesTran(String receiptId) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
      return;
    }

    List<Map<String, dynamic>> challengeList = await loadChallengeList();
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference agreementRef = FirebaseFirestore.instance
          .collection('user')
          .doc(authUid)
          .collection('agreement')
          .doc(authUid);

      DocumentReference statisticRef =
          FirebaseFirestore.instance.collection('statistic').doc(authUid);

      for (var challengeData in challengeList) {
        DocumentReference challengeRef = FirebaseFirestore.instance
            .collection('challenge')
            .doc(authUid)
            .collection('challenge')
            .doc();

        ChallengeModel challengeModel = ChallengeModel(
          docId: challengeRef.id,
          uid: authUid,
          receiptId: receiptId,
          category: challengeData['category'],
          goal: challengeData['goal'],
          status: 'apply',
          reportState: 'able',
          checkingState: 'none',
          pointState: 'wait',
          isVisible: false,
          paymentAgree: true,
          betPoint: int.parse(challengeData['betPoint']),
          deadline:
              Timestamp.fromDate(DateTime.parse(challengeData['selectedDate'])),
        );

        transaction.set(challengeRef, challengeModel.toJson());
      }
      transaction.update(statisticRef, {
        'totalChallenge': FieldValue.increment(challengeList.length),
        'monthChallenge': FieldValue.increment(challengeList.length),
      });
      if (isFirst) {
        transaction.update(agreementRef, {
          'termsConditions': true,
          'privacyPolicy': true,
          'pushAd':
              selectedCheckIndexs.isNotEmpty && !selectedCheckIndexs.contains(3)
                  ? false
                  : true,
        });
      }
    }).then((result) async {
      if (isFirst && selectedCheckIndexs.contains(3)) {
        await FirebaseMessaging.instance.subscribeToTopic("pushAd");
        InfoGetxToast.show(
          context,
          '수신동의 처리 완료',
          '전송자: Wanna Do\n일시: ${DateFormatUtilsSeven.formatDay(DateTime.now())}',
        );
      }
      Get.offAll(() => ChallengeEnd());
    }).catchError((e) {
      setState(() {
        isLoading = false;
        isClicked = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    });
  }

  Future<DateTime> getInternetDateTimeDio() async {
    var dio = Dio();
    var url = 'https://worldtimeapi.org/api/timezone/Asia/Seoul';

    try {
      var response = await dio.get(url);
      String dateTime = response.data['datetime'];
      DateTime now = DateTime.parse(dateTime);
      return now.toLocal();
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isLoading,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: SubAppBar(),
            body: FutureBuilder<List<Map<String, dynamic>>>(
                future: loadChallengeListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      child: Center(
                        child: Lottie.asset(
                          'asset/lottie/short_loading_first_animation.json',
                          height: 100,
                        ),
                      ),
                    );
                  }

                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('챌린지를 추가해주세요!'),
                    );
                  }

                  int totalBetPoint = snapshot.data!
                      .map((challenge) =>
                          int.parse(challenge['betPoint'] as String))
                      .reduce((value, element) => value + element);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ScrollConfiguration(
                              behavior: NoGlowScrollBehavior(),
                              child: SingleChildScrollView(
                                controller: scrollController,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Column(
                                        children: [
                                          Divider(
                                            thickness: 0.3,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '등록한 챌린지 수',
                                                        style: font15w700,
                                                      ),
                                                      SizedBox(height: 5),
                                                      Text(
                                                        '${snapshot.data!.length}개',
                                                        style: font15w400,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  '${NumberFormat('#,###').format(totalBetPoint)}원',
                                                  style: font15w700.copyWith(
                                                    color: mainColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(
                                            thickness: 0.3,
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
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '안내',
                                            style: font23w800,
                                          ),
                                          SizedBox(height: 20),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      '성공',
                                                      style:
                                                          font18w800.copyWith(
                                                        color: mainColor,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      size: 35,
                                                      color: mainColor
                                                          .withOpacity(0.9),
                                                    ),
                                                    Text(
                                                      '즉시 전액 환불',
                                                      style:
                                                          font18w800.copyWith(
                                                        color: mainColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '실패',
                                                      style:
                                                          font18w800.copyWith(
                                                        color: subColorDark,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      size: 35,
                                                      color: subColorDark
                                                          .withOpacity(0.9),
                                                    ),
                                                    Text(
                                                      '결제금 25% 임시적립금에 저장',
                                                      style:
                                                          font18w800.copyWith(
                                                        color: subColorDark,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 2,
                                                color: Colors.black
                                                    .withOpacity(0.8),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                '사진/영상으로 챌린지를 인증하면 \n24시간 내로 검사해드릴게요',
                                                style: font15w700.copyWith(
                                                    height: 1.5),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 30),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: EasyTooltip(
                                              bubbleWidth: 300,
                                              backgroundColor: mainColor,
                                              text:
                                                  '인증 최대치를 넘는다면 챌린지를 조금 수정해주세요. '
                                                  '너무 많으면 SNS 링크를 활용하는 것도 좋은 방법이에요!',
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '사진은 최대 30장, 영상은 20초까지 인증 가능해요',
                                                    style: font14w700.copyWith(
                                                      color: charcoalColor
                                                          .withOpacity(0.8),
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Icon(
                                                    Icons.info_outline_rounded,
                                                    color: charcoalColor
                                                        .withOpacity(0.8),
                                                    size: 19,
                                                  ),
                                                ],
                                              ),
                                              textStyle: font14w700.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 70),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '이용 규칙',
                                                  style: font23w800,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Get.to(() => RoleHome());
                                                },
                                                child: Text(
                                                  '자세히 보기',
                                                  style: font15w700.copyWith(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                size: 20,
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                'asset/img/write.png',
                                                height: 40,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                '1. 챌린지 목표는 구체적으로!',
                                                style: font23w800,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                '목표가 구체적이지 않아 판정하기 애매하면 \n인증과 관계없이 실패이니 조심해주세요',
                                                style: font15w400.copyWith(
                                                    height: 1.5),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 30),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                'asset/img/gallery.png',
                                                height: 40,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                '2. 인증은 정확하게!',
                                                style: font23w800,
                                              ),
                                              SizedBox(height: 10),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 12.0),
                                                child: Text(
                                                  '목표달성을 못했거나 인증 내역이 부정확해도 실패에요\n단, 부당하면 이의제기는 바로 가능해요',
                                                  style: font15w400.copyWith(
                                                      height: 1.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 30),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                'asset/img/honest.png',
                                                height: 40,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                '3. 누가봐도 떳떳하게!',
                                                style: font23w800,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                '선생님과 상사에게 검사 받는다고 생각해보세요\n누가봐도 목표 달성에 성공했다고 인정할 정도로요!',
                                                style: font15w400.copyWith(
                                                    height: 1.5),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        '*위의 규칙은 챌린지 이용 규칙에 대한 요약 사항이며, '
                                        '결제전 이용 규칙 및 약관 전문을 반드시 확인하시기 바랍니다.',
                                        style: font13w700.copyWith(
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '동의하기',
                                            style: font23w800,
                                          ),
                                          SizedBox(height: 20),
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: greyColor.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: List.generate(
                                                  isFirst ? 4 : 3,
                                                  (index) {
                                                    return Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    if (selectedCheckIndexs
                                                                        .contains(
                                                                            index)) {
                                                                      selectedCheckIndexs
                                                                          .remove(
                                                                              index);
                                                                    } else {
                                                                      selectedCheckIndexs
                                                                          .add(
                                                                              index);
                                                                    }
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  color: greyColor
                                                                      .withOpacity(
                                                                          0.0),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            8.0),
                                                                    child: Row(
                                                                      children: [
                                                                        Image
                                                                            .asset(
                                                                          'asset/img/check_mini2.png',
                                                                          color: selectedCheckIndexs.contains(index)
                                                                              ? mainColor
                                                                              : greyColor,
                                                                          height:
                                                                              17,
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                10),
                                                                        Text(
                                                                          checkTexts[
                                                                              index],
                                                                          style:
                                                                              font15w700,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                if (index ==
                                                                        0 ||
                                                                    index ==
                                                                        1) {
                                                                  Get.to(() =>
                                                                      AgreementHome());
                                                                } else if (index ==
                                                                    2) {
                                                                  InfoGetxToast.show(
                                                                      context,
                                                                      '성공시 바로 환불 처리 해드려요',
                                                                      '해당 은행 방침에 따라 최대 1-5일은 걸릴 수 있지만 누락되진 않아요');
                                                                }
                                                              },
                                                              child: Icon(
                                                                Icons
                                                                    .chevron_right_rounded,
                                                                size: 30,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.4),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 30),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.0),
                                      Colors.white,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      BigButtonFirst(
                        buttonText: isMaxScroll ? '동의하고 결제하기' : '아래로 스크롤',
                        onPressed: isClicked
                            ? null
                            : () async {
                                if (isMaxScroll) {
                                  if (selectedCheckIndexs.isEmpty) {
                                    setState(() {
                                      isClicked = true;
                                      selectedCheckIndexs.add(0);
                                    });
                                    await Future.delayed(
                                        Duration(milliseconds: 50));
                                    setState(() {
                                      selectedCheckIndexs.add(1);
                                    });
                                    await Future.delayed(
                                        Duration(milliseconds: 100));
                                    setState(() {
                                      selectedCheckIndexs.add(2);
                                    });
                                    await Future.delayed(
                                        Duration(milliseconds: 50));
                                    setState(() {
                                      selectedCheckIndexs.add(3);
                                      isLoading = true;
                                    });
                                    if (mounted) {
                                      await startBootpay(context);
                                    }
                                  } else if (!selectedCheckIndexs.contains(3)) {
                                    setState(() {
                                      isClicked = true;
                                      selectedCheckIndexs.add(0);
                                    });
                                    await Future.delayed(
                                        Duration(milliseconds: 50));
                                    setState(() {
                                      selectedCheckIndexs.add(1);
                                    });
                                    await Future.delayed(
                                        Duration(milliseconds: 100));
                                    setState(() {
                                      selectedCheckIndexs.add(2);
                                      isLoading = true;
                                    });
                                    await startBootpay(context);
                                  } else {
                                    setState(() {
                                      isClicked = true;
                                      selectedCheckIndexs.add(0);
                                    });
                                    await Future.delayed(
                                        Duration(milliseconds: 50));
                                    setState(() {
                                      selectedCheckIndexs.add(1);
                                    });
                                    await Future.delayed(
                                        Duration(milliseconds: 100));
                                    setState(() {
                                      selectedCheckIndexs.add(2);
                                    });
                                    await Future.delayed(
                                        Duration(milliseconds: 50));
                                    setState(() {
                                      selectedCheckIndexs.add(3);
                                      isLoading = true;
                                    });
                                    if (mounted) {
                                      await startBootpay(context);
                                    }
                                  }
                                } else if (!isMaxScroll) {
                                  scrollAnimateToPage();
                                }
                              }, // widget.onNext,
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            '챌린지를 다시 고칠래요',
                            style: font15w700.copyWith(
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                    ],
                  );
                }),
          ),
          if (isLoading) ShortLoadingFirst(),
        ],
      ),
    );
  }
}

// Future<void> applyChallenges() async {
//   try {
//     setState(() {
//       isLoading = true;
//     });
//
//     List<Map<String, dynamic>> challengeList = await loadChallengeList();
//     WriteBatch batch = FirebaseFirestore.instance.batch();
//
//     DocumentReference agreementRef = FirebaseFirestore.instance
//         .collection('user')
//         .doc(authUid)
//         .collection('agreement')
//         .doc(authUid);
//
//     DocumentReference statisticRef =
//         FirebaseFirestore.instance.collection('statistic').doc(authUid);
//
//     for (var challengeData in challengeList) {
//       DocumentReference challengeRef = FirebaseFirestore.instance
//           .collection('challenge')
//           .doc(authUid)
//           .collection('challenge')
//           .doc();
//
//       ChallengeModel challengeModel = ChallengeModel(
//         docId: challengeRef.id,
//         uid: authUid,
//         category: challengeData['category'],
//         goal: challengeData['goal'],
//         status: 'apply',
//         reportState: 'able',
//         checkingState: 'none',
//         pointState: 'wait',
//         isVisible: false,
//         paymentAgree: true,
//         betPoint: int.parse(challengeData['betPoint']),
//         deadline:
//             Timestamp.fromDate(DateTime.parse(challengeData['selectedDate'])),
//       );
//
//       batch.set(challengeRef, challengeModel.toJson());
//     }
//     batch.update(statisticRef, {
//       'totalChallenge': FieldValue.increment(challengeList.length),
//       'monthChallenge': FieldValue.increment(challengeList.length),
//     });
//     if (isApplyFirst) {
//       batch.update(agreementRef, {
//         'termsConditions': true,
//         'privacyPolicy': true,
//         'pushAd':
//             selectedCheckIndexs.isNotEmpty && !selectedCheckIndexs.contains(3)
//                 ? false
//                 : true,
//       });
//     }
//
//     await batch.commit().timeout(Duration(seconds: 10));
//     Get.offAll(() => ChallengeEnd());
//   } catch (e) {
//     setState(() {
//       isLoading = false;
//     });
//     ErrorGetxToast.show(
//       context,
//       '네트워크를 확인해주세요.',
//       '오류가 계속되면 MY탭에서 문의해주세요.',
//     );
//   }
// }
