import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/challenge_detail/challenge_detail_complain.dart';
import 'package:wanna_do/container/public/video_play.dart';
import 'package:wanna_do/container/help/role_home.dart';
import 'package:wanna_do/container/public/image_viewer.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ChallengeDetailResult extends StatefulWidget {
  final String goal;
  final String category;
  final String status;
  final String docId;
  final String? checker;
  final String? complainReason;
  final String? failReason;
  final String? thumbNailUrl;
  final int betPoint;
  final bool? isVideo;
  final bool? isVisible;
  final DateTime deadline;
  final DateTime? certifyAt;
  final DateTime? checkAt;
  final List<String>? certifyUrl;

  const ChallengeDetailResult({
    super.key,
    required this.goal,
    required this.category,
    required this.status,
    required this.docId,
    required this.betPoint,
    required this.deadline,
    this.checker,
    this.complainReason,
    this.failReason,
    this.thumbNailUrl,
    this.isVideo,
    this.isVisible,
    this.certifyAt,
    this.checkAt,
    this.certifyUrl,
  });

  @override
  State<ChallengeDetailResult> createState() => _ChallengeDetailResultState();
}

class _ChallengeDetailResultState extends State<ChallengeDetailResult> {
  late ScrollController scrollController = ScrollController();
  bool isMaxScroll = false;
  String reCheck = '';

  @override
  void initState() {
    super.initState();
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
    if (!scrollController.hasClients) {
      return;
    }
    await Future.delayed(Duration(milliseconds: 500));
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
    if (widget.status == 'lose' && widget.complainReason != null ||
        widget.status == 'win' && widget.failReason != null) {
      reCheck = '(재판정)';
    }
    double mainAxisSpacing = 10;
    double gridViewWidth = MediaQuery.of(context).size.width;
    double itemWidth = (gridViewWidth - 2 * 10) / 3;
    double gridViewHeight =
        (itemWidth + mainAxisSpacing) * (widget.certifyUrl!.length / 3).ceil() -
            mainAxisSpacing;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(
        title: '${challengeStatusTranslate(widget.status)}$reCheck',
      ),
      body: Column(
        children: [
          Expanded(
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
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
                                              DateFormatUtilsThird.formatDay(
                                                widget.deadline,
                                              ),
                                              style: font13w400,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${NumberFormat('#,###').format(
                                          widget.betPoint,
                                        )}원',
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
                                      widget.category,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CategoryBackgroundColorUtils.getColor(
                                    widget.category,
                                  ),
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
                    if (widget.isVideo != null && widget.isVideo!)
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
                                    videoUrl: widget.certifyUrl!.first,
                                  ),
                                );
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: AspectRatio(
                                      aspectRatio: 4 / 3,
                                      child: CachedNetworkImage(
                                        imageUrl: widget.thumbNailUrl!,
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
                                                  '저장기간 2개월이 지났어요',
                                                  style: font15w700.copyWith(
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
                    if (widget.isVideo != null && !widget.isVideo!)
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
                                            imageList: widget.certifyUrl!,
                                            initialIndex: index,
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: CachedNetworkImage(
                                          imageUrl: widget.certifyUrl![index],
                                          placeholder: (context, url) => Center(
                                            child: Lottie.asset(
                                              'asset/lottie/short_loading_first_animation.json',
                                              height: 80,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Column(
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
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: widget.certifyUrl!.length,
                                  physics: NeverScrollableScrollPhysics(),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    if (widget.status == 'win' || widget.status == 'lose')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '판정 정보 $reCheck',
                              style: font23w800,
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: greyColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.checker == 'Wanna Do 관리자')
                                      Text(
                                        '검사자 : ${widget.checker}',
                                        style: font15w700,
                                      ),
                                    if (widget.checker != 'Wanna Do 관리자')
                                      Text(
                                        '검사자 : ${widget.checker!.substring(0, widget.checker!.length >= 8 ? 4 : widget.checker!.length)}**** 님',
                                        style: font15w700,
                                      ),
                                    SizedBox(height: 10),
                                    Text(
                                      '검사일시 : ${DateFormatUtilsFifth.formatDay(widget.checkAt!)}',
                                      style: font15w700,
                                    ),
                                    if (widget.status == 'lose')
                                      Column(
                                        children: [
                                          SizedBox(height: 10),
                                          Text(
                                            '실패사유 : ${widget.failReason}',
                                            style: font15w700.copyWith(
                                                height: 1.3),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.status == 'certify')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  '검사는 얼마나 걸리나요?',
                                  style: font15w700.copyWith(
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              '워너두 담당자가 24시간 이내로 검사 해드리지만 조금은 더 걸릴 수 있어요.\n'
                              '만약 체크업에도 등록한 챌린지라면 빠르면 5분 내로도 검사가 가능해요.',
                              style: font15w400.copyWith(
                                height: 1.5,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    if (widget.status == 'complain')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  '이의제기는 무엇인가요?',
                                  style: font15w700.copyWith(
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              '잘못된 판정으로 인해 피해를 입는 여러분을 보호하기 위한 제도에요.\n'
                              '24시간 이내로 재판정해드리니, 부당한 판정이 확실하다면 언제든 이의제기를 이용해주세요.',
                              style: font15w400.copyWith(
                                height: 1.5,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    if (widget.status == 'win' || widget.status == 'lose')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 30),
                            Row(
                              children: [
                                Image.asset(
                                  'asset/img/guide.png',
                                  height: 20,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '판정이 잘못되었다면?',
                                  style: font15w700.copyWith(
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              '판정이 잘못되었다면 판정후 24시간 이내로 1번의 이의제기가 가능해요.\n'
                              '단, 무분별한 이의제기는 규정위반에 해당하며 챌린지 이용이 일부 제한될 수 있으니 조심해주세요.',
                              style: font15w400.copyWith(
                                height: 1.5,
                                color: Colors.black.withOpacity(0.5),
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
          ),
          if (widget.complainReason == null &&
              widget.isVideo != null &&
              widget.status != 'certify' &&
              !DateTime.now().isAfter(widget.checkAt!.add(Duration(days: 1))))
            Column(
              children: [
                SizedBox(height: 10),
                BigButtonFirst(
                  buttonText: '판정이 잘못 되었어요',
                  onPressed: () async {
                    await getInternetDateTimeDio().then((internetTime) async {
                      if (internetTime.isAfter(
                        widget.checkAt!.add(Duration(days: 1)),
                      )) {
                        ErrorGetxToast.show(context, '이의신청 기간이 지났어요',
                            '이의신청은 판정후 24시간 이내로 가능해요');
                      } else {
                        Get.to(
                          () => ChallengeDetailComPlain(
                            docId: widget.docId,
                            status: widget.status,
                            checker: widget.checker!,
                          ),
                        );
                      }
                    });
                  },
                  backgroundColor: mainColorLight,
                  textColor: mainColor,
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Get.to(() => RoleHome());
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
                      '판정기준 자세히 보기',
                      style: font15w700.copyWith(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
        ],
      ),
    );
  }
}
