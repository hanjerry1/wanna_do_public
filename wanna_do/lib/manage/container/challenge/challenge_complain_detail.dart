import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanna_do/container/help/role_home.dart';
import 'package:wanna_do/manage/container/challenge/challenge_complain_fail.dart';
import 'package:wanna_do/manage/container/user/user_manage.dart';
import 'package:wanna_do/model/challenge/challenge_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/public/video_play.dart';
import 'package:wanna_do/container/public/image_viewer.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ChallengeComplainDetail extends StatefulWidget {
  DocumentSnapshot challengeSnapshot;

  ChallengeComplainDetail({
    super.key,
    required this.challengeSnapshot,
  });

  @override
  State<ChallengeComplainDetail> createState() =>
      _ChallengeComplainDetailState();
}

class _ChallengeComplainDetailState extends State<ChallengeComplainDetail> {
  bool isLoading = false;

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
    ChallengeModel data = ChallengeModel.fromJson(
      widget.challengeSnapshot.data() as Map<String, dynamic>,
    );

    double mainAxisSpacing = 10;
    double gridViewWidth = MediaQuery.of(context).size.width;
    double itemWidth = (gridViewWidth - 2 * 10) / 3;
    double gridViewHeight =
        (itemWidth + mainAxisSpacing) * (data.certifyUrl!.length / 3).ceil() -
            mainAxisSpacing;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: SubAppBar(
              title: data.status == 'complain' ? '실패 이의제기' : '성공 이의제기',
              onBackButtonPressed: () async {
                Get.back();
              },
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
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
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
                                                    DateFormatUtilsSecond
                                                        .formatDay(
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
                                        color: CategoryBackgroundColorUtils
                                            .getColor(data.category),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Linkify(
                                        onOpen: (link) async {
                                          final Uri url = Uri.parse(link.url);
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url);
                                          } else {
                                            throw 'Could not launch $url';
                                          }
                                        },
                                        text: data.goal,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '항의이유',
                                          style: font15w800.copyWith(
                                            color: mainColor,
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        Expanded(
                                          child: Text(
                                            data.complainReason!,
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
                                                        '30일 저장기간이 지나 영상을 볼 수 없어요',
                                                        style:
                                                            font15w400.copyWith(
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
                                                  builder: (context) =>
                                                      ImageViewer(
                                                    imageList: data.certifyUrl!,
                                                    initialIndex: index,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: CachedNetworkImage(
                                              imageUrl: data.certifyUrl![index],
                                              placeholder: (context, url) =>
                                                  Center(
                                                child: Lottie.asset(
                                                  'asset/lottie/short_loading_first_animation.json',
                                                  height: 80,
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
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
                          SizedBox(height: 20),
                          SmallButtonFirst(
                            onPressed: () {
                              if (data.checker == 'Wanna Do 관리자') {
                                ErrorGetxToast.show(
                                    context, '검사자 알림', '검사자가 워너두 관리자에요');
                              } else {
                                Get.to(
                                  () => UserManage(
                                    uid: data.checker!,
                                  ),
                                );
                              }
                            },
                            backgroundColor: mainColor,
                            content: Text(
                              '검사자 체크업 경고하기',
                              style: font15w700.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                if (data.status == 'complain')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: MediumButtonSecond(
                            buttonText: '성공',
                            onPressed: () async {
                              try {
                                setState(() {
                                  isLoading = true;
                                });
                                WriteBatch batch =
                                    FirebaseFirestore.instance.batch();

                                QuerySnapshot querySnapshot =
                                    await FirebaseFirestore.instance
                                        .collection('service')
                                        .doc('challengeComplain')
                                        .collection('challengeComplain')
                                        .where('docId', isEqualTo: data.docId)
                                        .get();

                                if (querySnapshot.docs.isEmpty) {
                                  Get.back();
                                  ErrorGetxToast.show(context, '챌린지가 존재하지 않아요',
                                      '다른 챌린지를 검사해주세요');
                                  return;
                                }

                                String checkupDocId =
                                    querySnapshot.docs.first.id;

                                DocumentReference challengeComplainRef =
                                    FirebaseFirestore.instance
                                        .collection('service')
                                        .doc('challengeComplain')
                                        .collection('challengeComplain')
                                        .doc(checkupDocId);

                                Map<String, dynamic> updateData = {
                                  'checker': 'Wanna Do 관리자',
                                  'checkAt': Timestamp.fromDate(DateTime.now()),
                                  'checkingState': 'checked',
                                  'pointState': 'needless',
                                  'status': 'win',
                                };

                                Map<String, dynamic> originalData =
                                    querySnapshot.docs.first.data()
                                        as Map<String, dynamic>;

                                ChallengeModel newData =
                                    ChallengeModel.fromJson({
                                  ...originalData,
                                  ...updateData,
                                });

                                DocumentReference statisticRef =
                                    FirebaseFirestore.instance
                                        .collection('statistic')
                                        .doc(data.uid);

                                DocumentReference challengeRef =
                                    FirebaseFirestore.instance
                                        .collection('challenge')
                                        .doc(data.uid)
                                        .collection('challenge')
                                        .doc(data.docId);

                                batch.update(statisticRef, {
                                  'totalWin': FieldValue.increment(1),
                                  'monthWin': FieldValue.increment(1),
                                });
                                batch.set(challengeRef, newData.toJson());
                                QuerySnapshot requestQueueSnapshot =
                                    await challengeComplainRef
                                        .collection('requestQueue')
                                        .get();
                                for (var doc in requestQueueSnapshot.docs) {
                                  batch.delete(doc.reference);
                                }
                                batch.delete(challengeComplainRef);
                                await batch.commit();
                                cancelBootpayPayment(
                                  data.receiptId,
                                  checkupDocId,
                                  data.betPoint.toDouble(),
                                );

                                Get.back();
                              } catch (e) {
                                setState(() {
                                  isLoading = false;
                                });
                                ErrorGetxToast.show(context, '네트워크를 확인해주세요',
                                    '오류가 계속되면 MY탭에서 문의해주세요');
                              }
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
                                () => ChallengeComplainFail(
                                  docId: data.docId,
                                  uid: data.uid,
                                  goal: data.goal,
                                  category: data.category,
                                  betPoint: data.betPoint,
                                  checker: data.checker!,
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
                if (data.status == 'win')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: BigButtonSecond(
                      buttonText: '확인하고 요청 삭제하기',
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        WriteBatch batch = FirebaseFirestore.instance.batch();

                        QuerySnapshot querySnapshot = await FirebaseFirestore
                            .instance
                            .collection('service')
                            .doc('challengeComplain')
                            .collection('challengeComplain')
                            .where('docId', isEqualTo: data.docId)
                            .get();

                        String checkupDocId = querySnapshot.docs.first.id;

                        DocumentReference challengeComplainRef =
                            FirebaseFirestore.instance
                                .collection('service')
                                .doc('challengeComplain')
                                .collection('challengeComplain')
                                .doc(checkupDocId);

                        QuerySnapshot requestQueueSnapshot =
                            await challengeComplainRef
                                .collection('requestQueue')
                                .get();
                        for (var doc in requestQueueSnapshot.docs) {
                          batch.delete(doc.reference);
                        }
                        batch.delete(challengeComplainRef);
                        await batch.commit();
                        Get.back();
                      },
                      backgroundColor: mainColorLight,
                      textColor: mainColor,
                    ),
                  ),
                SizedBox(height: 15),
              ],
            ),
          ),
          if (isLoading) ShortLoadingFirst(),
        ],
      ),
    );
  }
}
