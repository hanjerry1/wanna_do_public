import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/help/role_home.dart';
import 'package:wanna_do/container/space/space_my_profile.dart';
import 'package:wanna_do/container/space/space_post.dart';
import 'package:wanna_do/model/space/space_model.dart';
import 'package:wanna_do/model/statistic/statistic_model.dart';
import 'package:wanna_do/model/user/user_model.dart';
import 'package:wanna_do/model/user/user_state_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/dialog_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class SpaceMy extends StatefulWidget {
  final String rank1Uid;
  final String rank2Uid;
  final String rank3Uid;

  SpaceMy({
    super.key,
    required this.rank1Uid,
    required this.rank2Uid,
    required this.rank3Uid,
  });

  @override
  State<SpaceMy> createState() => _SpaceMyState();
}

class _SpaceMyState extends State<SpaceMy> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final ScrollController scrollController1 = ScrollController();
  final ScrollController scrollController2 = ScrollController();
  List<DocumentSnapshot> docMyPostList = [];
  List<DocumentSnapshot> docMyLikePostList = [];
  DocumentSnapshot? lastMyPostDocument;
  DocumentSnapshot? lastMyLikePostDocument;
  String nickname = '';
  String spaceState = '0';
  int totalMyPost = 0;
  int totalMyLikePost = 0;
  bool isMoreLoading = false;
  bool isLoading = false;
  bool hasMoreData1 = true;
  bool hasMoreData2 = true;

  @override
  void initState() {
    super.initState();
    loadInitUserData();
    loadInitUserSpaceStateData();
    loadInitStatisticData();
    loadInitMyPostData();
    loadInitMyLikePostData();
    scrollController1.addListener(scrollListener1);
    scrollController2.addListener(scrollListener2);
  }

  @override
  void dispose() {
    scrollController1.dispose();
    scrollController2.dispose();
    super.dispose();
  }

  void scrollListener1() async {
    if (scrollController1.position.pixels ==
            scrollController1.position.maxScrollExtent &&
        !isMoreLoading &&
        hasMoreData1) {
      await loadMoreMyPostData();
    }
  }

  void scrollListener2() async {
    if (scrollController2.position.pixels ==
            scrollController2.position.maxScrollExtent &&
        !isMoreLoading &&
        hasMoreData2) {
      await loadMoreMyLikePostData();
    }
  }

  Future<void> loadInitUserData() async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('user').doc(authUid).get();

    UserModel data = UserModel.fromJson(
      documentSnapshot.data() as Map<String, dynamic>,
    );

    setState(() {
      nickname = data.nickname!;
    });
  }

  Future<void> loadInitUserSpaceStateData() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(authUid)
        .collection('userState')
        .doc(authUid)
        .get();

    UserStateModel data = UserStateModel.fromJson(
      documentSnapshot.data() as Map<String, dynamic>,
    );

    setState(() {
      spaceState = data.spaceState;
    });
  }

  Future<void> loadInitStatisticData() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('statistic')
        .doc(authUid)
        .get();

    StatisticModel data = StatisticModel.fromJson(
      documentSnapshot.data() as Map<String, dynamic>,
    );

    setState(() {
      totalMyPost = data.totalMyPost;
      totalMyLikePost = data.totalMyLikePost;
    });
  }

  Future<void> loadInitMyPostData() async {
    docMyPostList = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('space')
        .where('uid', isEqualTo: authUid)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        docMyPostList.add(doc);
      }
      setState(() {
        lastMyPostDocument = docMyPostList.last;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadInitMyLikePostData() async {
    docMyLikePostList = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('space')
        .where('likeUids', arrayContains: authUid)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        docMyLikePostList.add(doc);
      }
      setState(() {
        lastMyLikePostDocument = docMyLikePostList.last;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadMoreMyPostData() async {
    if (isMoreLoading) return;
    setState(() {
      isMoreLoading = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('space')
        .where('uid', isEqualTo: authUid)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastMyPostDocument!)
        .limit(5)
        .get();

    if (querySnapshot.docs.isEmpty) {
      hasMoreData1 = false;
    } else {
      lastMyPostDocument = querySnapshot.docs.last;
      docMyPostList.addAll(querySnapshot.docs);
    }
    setState(() {
      isMoreLoading = false;
    });
  }

  Future<void> loadMoreMyLikePostData() async {
    if (isMoreLoading) return;
    setState(() {
      isMoreLoading = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('space')
        .where('likeUids', arrayContains: authUid)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastMyLikePostDocument!)
        .limit(5)
        .get();

    if (querySnapshot.docs.isEmpty) {
      hasMoreData2 = false;
    } else {
      lastMyLikePostDocument = querySnapshot.docs.last;
      docMyLikePostList.addAll(querySnapshot.docs);
    }
    setState(() {
      isMoreLoading = false;
    });
  }

  Future<void> reloadOneMyPostData(String docId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('space').doc(docId).get();

      if (documentSnapshot.exists) {
        var updatedPost = documentSnapshot;

        int indexToUpdate = docMyPostList.indexWhere((doc) => doc.id == docId);
        if (indexToUpdate != -1) {
          setState(() {
            docMyPostList[indexToUpdate] = updatedPost;
          });
        }
      }
    } catch (e) {}
  }

  Future<void> reloadOneMyLikePostData(String docId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('space').doc(docId).get();

      if (documentSnapshot.exists) {
        var updatedPost = documentSnapshot;

        int indexToUpdate =
            docMyLikePostList.indexWhere((doc) => doc.id == docId);
        if (indexToUpdate != -1) {
          setState(() {
            docMyLikePostList[indexToUpdate] = updatedPost;
          });
        }
      }
    } catch (e) {}
  }

  String spaceStateTranslate(String checkupState) {
    switch (checkupState) {
      case '0':
        return '없음';
      case '1':
        return '경고';
      case '2':
        return '경고';
      case '3':
        return '제한';
      default:
        return '없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> columnsData = [
      {"label": "규정위반", "value": spaceStateTranslate(spaceState)},
      {"label": "내 글", "value": "$totalMyPost"},
      {"label": "좋아요", "value": "$totalMyLikePost"},
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SubAppBar(
          title: '스페이스 활동',
        ),
        body: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      nickname,
                      style: font20w700,
                    ),
                  ),
                  Image.asset(
                    'asset/img/my_user.png',
                    height: 55,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: columnsData.map((data) {
                  return Padding(
                    padding: EdgeInsets.only(right: 15),
                    child: GestureDetector(
                      onTap: () {
                        if (data['label'] == '규정위반') {
                          Get.dialog(
                            DialogTwoButton(
                              title: '규정 위반 안내',
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '없음 - 규정 위반 횟수 0회',
                                    style: font15w700.copyWith(
                                      height: 1.5,
                                    ),
                                  ),
                                  Text(
                                    '경고 - 규정 위반 횟수 1-2회',
                                    style: font15w700.copyWith(
                                      height: 1.5,
                                      color: orangeColor,
                                    ),
                                  ),
                                  Text(
                                    '제한 - 규정 위반 횟수 3회',
                                    style: font15w700.copyWith(
                                      height: 1.5,
                                      color: redColor,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    '제한된 경우, 커뮤니티 이용이 불가하며 다시 이용을 원할 경우 고객센터로 직접 연락해주세요.'
                                    '\n(위반 횟수는 예고없이 초기화됩니다.)',
                                    style: font15w700.copyWith(
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                              leftText: '확인',
                              rightText: '규정 확인하기',
                              onLeftButtonPressed: () {
                                Get.back();
                              },
                              onRightButtonPressed: () {
                                Get.to(() => RoleHome());
                              },
                            ),
                          );
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['label']!,
                            style: font15w400,
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                data['value']!,
                                style: font18w700.copyWith(
                                  color: data['label'] == '규정위반'
                                      ? spaceState == '3'
                                          ? redColor
                                          : spaceState == '0'
                                              ? Colors.black
                                              : orangeColor
                                      : Colors.black,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: data['label'] == '규정위반'
                                    ? Colors.black.withOpacity(0.5)
                                    : Colors.black.withOpacity(0),
                                size: 25,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BigButtonSecond(
                    buttonText: '프로필 수정',
                    backgroundColor: mainColorLight,
                    textColor: mainColor,
                    onPressed: () {
                      Get.to(
                        () => SpaceMyProfile(
                          nickname: nickname,
                        ),
                      )!
                          .then((_) {
                        loadInitUserData();
                      });
                    },
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
            TabBar(
              tabs: [
                Tab(text: '내 글'),
                Tab(text: '좋아요'),
              ],
              labelColor: charcoalColor,
              labelStyle: font18w800.copyWith(fontFamily: 'NanumSquare'),
              unselectedLabelColor: charcoalColor.withOpacity(0.3),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 2,
                  color: charcoalColor,
                ),
                insets: EdgeInsets.symmetric(horizontal: 50),
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: ScrollConfiguration(
                      behavior: NoGlowScrollBehavior(),
                      child: ListView.separated(
                        controller: scrollController1,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot spaceSnapshot = docMyPostList[index];

                          SpaceModel data = SpaceModel.fromJson(
                            spaceSnapshot.data() as Map<String, dynamic>,
                          );
                          reloadOneMyPostData(data.docId);

                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: GestureDetector(
                              onTap: () async {
                                Get.to(
                                  () => SpacePost(
                                    docId: data.docId,
                                    title: data.title,
                                    content: data.content,
                                    createdAt: data.createdAt!.toDate(),
                                    editAt: data.editAt?.toDate(),
                                    isUnknown: data.isUnknown,
                                    nickname: data.nickname,
                                    likeCount: data.likeCount,
                                    chatCount: data.chatCount,
                                    postUrl: data.postUrl ?? [],
                                    uid: data.uid,
                                    likeUids: data.likeUids ?? [],
                                    rank1Uid: widget.rank1Uid,
                                    rank2Uid: widget.rank2Uid,
                                    rank3Uid: widget.rank3Uid,
                                  ),
                                )!
                                    .then((_) {
                                  reloadOneMyPostData(data.docId);
                                });
                              },
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text(
                                                TextFormatUtilsOne.formatText(
                                                  data.title,
                                                ),
                                                style: font15w700,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              if (data.postUrl!.isNotEmpty)
                                                Row(
                                                  children: [
                                                    SizedBox(width: 5),
                                                    SvgPicture.asset(
                                                      'asset/svg/image.svg',
                                                      color: mainColor,
                                                      height: 16,
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          DateFormatUtilsSixth.formatDay(
                                              data.createdAt!.toDate()),
                                          style: font13w400.copyWith(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      data.content,
                                      style: font15w400,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    SizedBox(height: 3),
                                    Container(
                                      height: 17,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    data.isUnknown
                                                        ? '익명'
                                                        : data.nickname,
                                                    style: font13w400.copyWith(
                                                        color: Colors.black
                                                            .withOpacity(0.4)),
                                                  ),
                                                  SizedBox(width: 3),
                                                  if (data.uid ==
                                                      widget.rank1Uid)
                                                    Image.asset(
                                                      'asset/img/medal_first.png',
                                                      height: 15,
                                                    ),
                                                  if (data.uid ==
                                                      widget.rank2Uid)
                                                    Image.asset(
                                                      'asset/img/medal_second.png',
                                                      height: 15,
                                                    ),
                                                  if (data.uid ==
                                                      widget.rank3Uid)
                                                    Image.asset(
                                                      'asset/img/medal_third.png',
                                                      height: 15,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              if (data.likeCount != 0)
                                                Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'asset/svg/space_heart.svg',
                                                      height: 15,
                                                      color: subColorDark,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      data.likeCount.toString(),
                                                      style:
                                                          font15w800.copyWith(
                                                        color: subColorDark,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              if (data.chatCount != 0)
                                                Row(
                                                  children: [
                                                    SizedBox(width: 10),
                                                    SvgPicture.asset(
                                                      'asset/svg/space_chat.svg',
                                                      height: 15,
                                                      color: mainColor,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      data.chatCount.toString(),
                                                      style:
                                                          font15w800.copyWith(
                                                        color: mainColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            thickness: 0.3,
                          );
                        },
                        itemCount: docMyPostList.length,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: ScrollConfiguration(
                      behavior: NoGlowScrollBehavior(),
                      child: ListView.separated(
                        controller: scrollController2,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot spaceSnapshot =
                              docMyLikePostList[index];

                          SpaceModel data = SpaceModel.fromJson(
                            spaceSnapshot.data() as Map<String, dynamic>,
                          );

                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: GestureDetector(
                              onTap: () async {
                                Get.to(
                                  () => SpacePost(
                                    docId: data.docId,
                                    title: data.title,
                                    content: data.content,
                                    createdAt: data.createdAt!.toDate(),
                                    editAt: data.editAt?.toDate(),
                                    isUnknown: data.isUnknown,
                                    nickname: data.nickname,
                                    likeCount: data.likeCount,
                                    chatCount: data.chatCount,
                                    postUrl: data.postUrl ?? [],
                                    uid: data.uid,
                                    likeUids: data.likeUids ?? [],
                                    rank1Uid: widget.rank1Uid,
                                    rank2Uid: widget.rank2Uid,
                                    rank3Uid: widget.rank3Uid,
                                  ),
                                )!
                                    .then((_) {
                                  reloadOneMyPostData(data.docId);
                                });
                              },
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text(
                                                TextFormatUtilsOne.formatText(
                                                  data.title,
                                                ),
                                                style: font15w700,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              if (data.postUrl!.isNotEmpty)
                                                Row(
                                                  children: [
                                                    SizedBox(width: 5),
                                                    SvgPicture.asset(
                                                      'asset/svg/image.svg',
                                                      color: mainColor,
                                                      height: 16,
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          DateFormatUtilsSixth.formatDay(
                                              data.createdAt!.toDate()),
                                          style: font13w400.copyWith(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      data.content,
                                      style: font15w400,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    SizedBox(height: 3),
                                    Container(
                                      height: 17,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    data.isUnknown
                                                        ? '익명'
                                                        : data.nickname,
                                                    style: font13w400.copyWith(
                                                        color: Colors.black
                                                            .withOpacity(0.4)),
                                                  ),
                                                  SizedBox(width: 3),
                                                  if (data.uid ==
                                                      widget.rank1Uid)
                                                    Image.asset(
                                                      'asset/img/medal_first.png',
                                                      height: 15,
                                                    ),
                                                  if (data.uid ==
                                                      widget.rank2Uid)
                                                    Image.asset(
                                                      'asset/img/medal_second.png',
                                                      height: 15,
                                                    ),
                                                  if (data.uid ==
                                                      widget.rank3Uid)
                                                    Image.asset(
                                                      'asset/img/medal_third.png',
                                                      height: 15,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              if (data.likeCount != 0)
                                                Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'asset/svg/space_heart.svg',
                                                      height: 15,
                                                      color: subColorDark,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      data.likeCount.toString(),
                                                      style:
                                                          font15w800.copyWith(
                                                        color: subColorDark,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              if (data.chatCount != 0)
                                                Row(
                                                  children: [
                                                    SizedBox(width: 10),
                                                    SvgPicture.asset(
                                                      'asset/svg/space_chat.svg',
                                                      height: 15,
                                                      color: mainColor,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      data.chatCount.toString(),
                                                      style:
                                                          font15w800.copyWith(
                                                        color: mainColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            thickness: 0.3,
                          );
                        },
                        itemCount: docMyLikePostList.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
