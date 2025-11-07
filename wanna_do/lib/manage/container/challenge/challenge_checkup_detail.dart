import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanna_do/container/help/role_home.dart';
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
import 'package:wanna_do/util/util_tool.dart';

class ChallengeCheckupDetail extends StatefulWidget {
  DocumentSnapshot challengeSnapshot;

  ChallengeCheckupDetail({
    super.key,
    required this.challengeSnapshot,
  });

  @override
  State<ChallengeCheckupDetail> createState() => _ChallengeCheckupDetailState();
}

class _ChallengeCheckupDetailState extends State<ChallengeCheckupDetail> {
  bool isLoading = false;

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

    return Stack(
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
                        '판단기준보기',
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
                                      color:
                                          CategoryBackgroundColorUtils.getColor(
                                              data.category),
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
                                        data.failReason == null
                                            ? '성공판정'
                                            : '실패판정',
                                        style: font15w800.copyWith(
                                          color: mainColor,
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Expanded(
                                        child: Text(
                                          data.failReason ?? '',
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
                                    Get.to(
                                      () => VideoPlay(
                                        videoUrl: data.certifyUrl!.first,
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
                                                (context, url, error) => Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.max,
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
                                            Get.to(
                                              () => ImageViewer(
                                                imageList: data.certifyUrl!,
                                                initialIndex: index,
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
                            Get.to(
                              () => UserManage(
                                uid: data.checker!,
                              ),
                            );
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BigButtonSecond(
                  buttonText: '확인하고 기록 삭제하기',
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('log')
                        .doc('checkupLog')
                        .collection('checkupLog')
                        .doc(widget.challengeSnapshot.id)
                        .delete();

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
    );
  }
}
