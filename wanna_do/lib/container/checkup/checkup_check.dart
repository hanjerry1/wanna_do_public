import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanna_do/component/main_page.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/help/role_home.dart';
import 'package:wanna_do/container/public/video_play.dart';
import 'package:wanna_do/container/checkup/checkup_fail.dart';
import 'package:wanna_do/container/public/image_viewer.dart';
import 'package:wanna_do/controller/page/main_page_controller.dart';
import 'package:wanna_do/model/challenge/challenge_model.dart';
import 'package:wanna_do/model/checkup/checkup_log_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class CheckupCheck extends StatefulWidget {
  final String docId;
  final String uid;
  final String reciptId;
  final String goal;
  final String category;
  final String thumbNailUrl;
  final int betPoint;
  final bool isVideo;
  final DateTime deadline;
  final DateTime certifyAt;
  final List<String> certifyUrl;

  const CheckupCheck({
    super.key,
    required this.docId,
    required this.uid,
    required this.goal,
    required this.category,
    required this.thumbNailUrl,
    required this.betPoint,
    required this.isVideo,
    required this.deadline,
    required this.certifyAt,
    required this.certifyUrl,
    required this.reciptId,
  });

  @override
  State<CheckupCheck> createState() => _CheckupCheckState();
}

class _CheckupCheckState extends State<CheckupCheck> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  late ScrollController scrollController = ScrollController();
  DateTime internetTime = DateTime.now();
  bool isMaxScroll = false;
  bool isLoading = false;
  bool isLink = false;

  @override
  void initState() {
    super.initState();
    getInternetDateTimeDio();
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
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollAnimateToPage());
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollAnimateToPage() async {
    await Future.delayed(Duration(milliseconds: 500));
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> sendWinChallenge() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
        return;
      }

      setState(() {
        isLoading = true;
      });

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('checkup')
          .where('docId', isEqualTo: widget.docId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
          Get.put(MainPageController(initialTabIndex: 1));
        }));
        ErrorGetxToast.show(context, '이미 처리된 챌린지에요', '다른 챌린지를 검사해주세요');
        return;
      }

      String checkupDocId = querySnapshot.docs.first.id;

      DocumentReference checkupRef =
          FirebaseFirestore.instance.collection('checkup').doc(checkupDocId);

      Map<String, dynamic> updateData = {
        'checker': authUid,
        'checkAt': Timestamp.fromDate(internetTime),
        'checkingState': 'checked',
        'pointState': 'needless',
        'status': 'win',
      };

      Map<String, dynamic> originalData =
          querySnapshot.docs.first.data() as Map<String, dynamic>;

      ChallengeModel newData = ChallengeModel.fromJson({
        ...originalData,
        ...updateData,
      });

      DocumentReference checkupLogRef = FirebaseFirestore.instance
          .collection('log')
          .doc('checkupLog')
          .collection('checkupLog')
          .doc();

      CheckupRecordModel checkupRecordModel = CheckupRecordModel(
        thatDocId: widget.docId,
        uid: widget.uid,
        goal: widget.goal,
        category: widget.category,
        status: 'win',
        pointState: 'needless',
        betPoint: widget.betPoint,
      );

      DocumentReference checkupRecordRef = FirebaseFirestore.instance
          .collection('checkupRecord')
          .doc(authUid)
          .collection('checkupRecord')
          .doc(widget.docId);

      DocumentReference statisticRef =
          FirebaseFirestore.instance.collection('statistic').doc(widget.uid);

      DocumentReference statisticMyRef =
          FirebaseFirestore.instance.collection('statistic').doc(authUid);

      DocumentReference challengeRef = FirebaseFirestore.instance
          .collection('challenge')
          .doc(widget.uid)
          .collection('challenge')
          .doc(widget.docId);

      QuerySnapshot requestQueueSnapshot =
          await checkupRef.collection('requestQueue').get();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(checkupLogRef, newData.toJson());
        transaction.set(checkupRecordRef, checkupRecordModel.toJson());
        transaction.update(statisticRef, {
          'totalWin': FieldValue.increment(1),
          'monthWin': FieldValue.increment(1),
        });
        transaction.update(statisticMyRef, {
          'totalCheckup': FieldValue.increment(1),
          'monthCheckup': FieldValue.increment(1),
        });
        transaction.set(challengeRef, newData.toJson());

        for (var doc in requestQueueSnapshot.docs) {
          transaction.delete(doc.reference);
        }
        transaction.delete(checkupRef);
      }).then((result) async {
        cancelBootpayPayment(
          widget.reciptId,
          checkupDocId,
          widget.betPoint.toDouble(),
        );
        Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
          Get.put(MainPageController(initialTabIndex: 1));
        }));
        InfoGetxToast.show(context, '성공 처리 완료', '언제나 꼼꼼하고 세심하게 봐주셔서 감사해요');
      }).catchError((e) {
        setState(() {
          isLoading = false;
        });
        ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> sendIffyChallenge() async {
    try {
      setState(() {
        isLoading = true;
      });
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('checkup')
          .where('docId', isEqualTo: widget.docId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
          Get.put(MainPageController(initialTabIndex: 1));
        }));
        ErrorGetxToast.show(context, '이미 처리된 챌린지에요', '다른 챌린지를 검사해주세요');
        return;
      }

      String checkupDocId = querySnapshot.docs.first.id;

      await FirebaseFirestore.instance
          .collection('checkup')
          .doc(checkupDocId)
          .update({
        'checkingState': 'iffy',
      });

      Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
        Get.put(MainPageController(initialTabIndex: 1));
      }));
      InfoGetxToast.show(context, '애매한 챌린지 처리 완료', '애매하면 고민하지 말고 저희에게 보내주세요');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> getInternetDateTimeDio() async {
    var dio = Dio();
    var url = 'https://worldtimeapi.org/api/timezone/Asia/Seoul';
    try {
      var response = await dio.get(url);
      String dateTime = response.data['datetime'];
      DateTime now = DateTime.parse(dateTime);
      setState(() {
        internetTime = now.toLocal();
      });
    } catch (e) {
      setState(() {
        internetTime = DateTime.now();
      });
    }
  }

  // 클라이언트에서 클라우드 함수 트리거시 꼭 필요한 설정.
  // 1. 구글 클라우드의 cloud functions에서 트리거의 대상이 되는 클라우드 함수의 권한을 모든 사용자가 접근할 수 있도록 추가해야함.
  // 2. 클라이언트 callable에서 try,catch 구문으로 오류처리를 해야함.
  // 3. 파이어베이스 앱체크는 필수는 아닌것 같긴한데, 혹시 안되면 앱체크도 등록하자.
  // Future<void> callCheckupToChallengeAndDeleteFunction(
  //     String checkupDocId) async {
  //   await FirebaseFunctions.instanceFor(region: 'asia-northeast3')
  //       .httpsCallable('checkupToChallengeAndDelete')
  //       .call(<String, dynamic>{
  //     'checkupDocId': checkupDocId,
  //   });
  // }

  // 클라우드 함수 호출시, 구글 클라우드 콘솔에서 해당 함수의 allUser권한이 필요함. 그래야 모든 사용자가 서버의 특정 클라우드함수를 호출할 수 있음.
  // 테스트 MID 사용시 체크카드 거래인 경우에는 부분취소 불가능 거래(전체취소 요망).

  Future<void> cancelBootpayPayment(
      String receiptId, String checkupDocId, double cancelPrice) async {
    try {
      await FirebaseFunctions.instanceFor(region: 'asia-northeast3')
          .httpsCallable('cancelBootpayPayment')
          .call(<String, dynamic>{
        'receipt_id': receiptId,
        'cancel_price': cancelPrice,
        'cancel_id': checkupDocId, // 중복취소 방지위한 고유 id
        'secretKey': dotenv.env['CLOUD_FUNCTIONS_SECRET_KEY'] ?? '',
      });
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double mainAxisSpacing = 10;
    double gridViewWidth = MediaQuery.of(context).size.width;
    double itemWidth = (gridViewWidth - 2 * 10) / 3;
    double gridViewHeight =
        (itemWidth + mainAxisSpacing) * (widget.certifyUrl.length / 3).ceil() -
            mainAxisSpacing;
    isLink = IsTextLink.containLink(widget.goal);

    return WillPopScope(
      onWillPop: () async {
        ErrorGetxToast.show(context, '판정을 꼭 완료해주세요', '한번 선택한 체크업은 뒤로갈 수 없어요');
        return false;
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: SubAppBar(
              actions: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => RoleHome());
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black.withOpacity(0.8),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          '체크업 규정',
                          style: font15w700.copyWith(
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: NoGlowScrollBehavior(),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                Column(
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
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.category,
                                                  style: font15w700,
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  DateFormatUtilsThird
                                                      .formatDay(
                                                    widget.deadline,
                                                  ),
                                                  style: font13w400,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '? 원',
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
                                              widget.category),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CategoryBackgroundColorUtils
                                            .getColor(widget.category),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Linkify(
                                        linkStyle: font15w700.copyWith(
                                          color: mainColor,
                                          height: 1.5,
                                        ),
                                        onOpen: (link) async {
                                          final Uri url = Uri.parse(link.url);
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url);
                                          } else {
                                            throw 'Could not launch $url';
                                          }
                                        },
                                        text: widget.goal,
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
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '참고!',
                                          style: font15w800.copyWith(
                                            color: mainColor,
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        Expanded(
                                          child: Text(
                                            '실패로 처리된 사용자가 24시간 내로 이의제기를 하지 않으면 나에게 내기금액 25%가 적립돼요',
                                            style: font13w400.copyWith(
                                              color:
                                                  Colors.black.withOpacity(0.8),
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
                          if (widget.isVideo)
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
                                  if (isLink)
                                    Column(
                                      children: [
                                        Text(
                                          'SNS 링크가 있다면 해당 링크를 눌러 게시물을 확인하고 인증해주세요. '
                                          '만약 링크가 이상하거나 게시물 확인이 어렵다면 실패처리 하지말고 애매한 챌린지로 처리해주세요.',
                                          style: font14w700.copyWith(
                                            color: charcoalColor,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(
                                        () => VideoPlay(
                                          videoUrl: widget.certifyUrl.first,
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: AspectRatio(
                                            aspectRatio: 4 / 3,
                                            child: CachedNetworkImage(
                                              imageUrl: widget.thumbNailUrl,
                                              placeholder: (context, url) =>
                                                  Center(
                                                child: Lottie.asset(
                                                  'asset/lottie/short_loading_first_animation.json',
                                                  height: 100,
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 30),
                                                      child: Text(
                                                        '저장기간 2개월이 지났어요',
                                                        style:
                                                            font15w700.copyWith(
                                                          color: orangeColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Icon(
                                            Icons.play_circle_outline_rounded,
                                            size: 100,
                                            color:
                                                Colors.black.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          if (!widget.isVideo)
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
                                  if (isLink)
                                    Column(
                                      children: [
                                        Text(
                                          'SNS 링크가 있다면 해당 링크를 눌러 게시물을 확인하고 인증해주세요. '
                                          '만약 링크가 이상하거나 게시물 확인이 어렵다면 실패처리 하지말고 애매한 챌린지로 처리해주세요.',
                                          style: font14w700.copyWith(
                                            color: charcoalColor,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    ),
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
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return GestureDetector(
                                            onTap: () {
                                              Get.to(
                                                () => ImageViewer(
                                                  imageList: widget.certifyUrl,
                                                  initialIndex: index,
                                                ),
                                              );
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    widget.certifyUrl[index],
                                                placeholder: (context, url) =>
                                                    Center(
                                                  child: Lottie.asset(
                                                    'asset/lottie/short_loading_first_animation.json',
                                                    height: 80,
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .error_outline_rounded,
                                                      size: 25,
                                                      color: orangeColor,
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      '저장기간 초과',
                                                      style:
                                                          font15w700.copyWith(
                                                        color: orangeColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                        itemCount: widget.certifyUrl.length,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          SizedBox(height: 20),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'asset/img/guide.png',
                                      height: 20,
                                      color: Colors.black.withOpacity(0.7),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      '내가 판정을 잘못했다면?',
                                      style: font15w700.copyWith(
                                        color: Colors.black.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '챌린지 판정을 잘못하면 규정위반에 해당하며 체크업 이용이 영구적으로 제한될 수 있어요.\n'
                                  '애매하면 넘겨도 좋아요. 워너두가 대신 해드리니 걱정마세요.',
                                  style: font15w400.copyWith(
                                    height: 1.5,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: MediumButtonSecond(
                          buttonText: '성공',
                          onPressed: () async {
                            await sendWinChallenge();
                          },
                          backgroundColor: mainColorLight,
                          textColor: mainColor,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: MediumButtonSecond(
                          buttonText: '실패',
                          onPressed: () {
                            Get.to(
                              () => CheckupFail(
                                docId: widget.docId,
                                uid: widget.uid,
                                goal: widget.goal,
                                category: widget.category,
                                betPoint: widget.betPoint,
                              ),
                            );
                          },
                          backgroundColor: redColorLight,
                          textColor: redColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    await sendIffyChallenge();
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
                      '판정하기 애매해요',
                      style: font15w700.copyWith(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          if (isLoading) ShortLoadingFirst(),
        ],
      ),
    );
  }
}
