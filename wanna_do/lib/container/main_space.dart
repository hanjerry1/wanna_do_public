import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/help/contact_home.dart';
import 'package:wanna_do/container/space/space_my.dart';
import 'package:wanna_do/container/space/space_post.dart';
import 'package:wanna_do/container/space/space_search.dart';
import 'package:wanna_do/container/space/space_writing.dart';
import 'package:wanna_do/model/space/space_model.dart';
import 'package:wanna_do/model/user/user_state_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class MainSpace extends StatefulWidget {
  final String rank1Uid;
  final String rank2Uid;
  final String rank3Uid;

  const MainSpace({
    super.key,
    required this.rank1Uid,
    required this.rank2Uid,
    required this.rank3Uid,
  });

  @override
  State<MainSpace> createState() => _MainSpaceState();
}

class _MainSpaceState extends State<MainSpace> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final ScrollController scrollController = ScrollController();
  final List<String> buttonTexts = ['자유', '학습자료', '🔥인기글'];
  List<DocumentSnapshot> docFreeList = [];
  List<DocumentSnapshot> docStudyList = [];
  List<DocumentSnapshot> docHotList = [];
  List<DocumentSnapshot> docFutureList = [];
  List<String> userBlockList = [];
  DocumentSnapshot? lastFreeDocument;
  DocumentSnapshot? lastStudyDocument;
  DocumentSnapshot? lastHotDocument;
  DocumentSnapshot? userStateDocument;
  DateTime? lastRefreshTime;

  int selectedButtonIndex = 0;
  int totalLoadedFreeDataCount = 0;
  int totalLoadedHotDataCount = 0;

  bool isUnable = false;
  bool isMoreLoading = false;
  bool isLoading = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    getUserStateSpace();
    loadInitFreeData();
    loadInitHotData();
    loadUserBlock();
    docFutureList = docFreeList;
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
      if (selectedButtonIndex == 0) {
        await loadMoreFreeData();
      } else if (selectedButtonIndex == 1) {
      } else if (selectedButtonIndex == 2) {
        await loadMoreHotData();
      }
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

      if (selectedButtonIndex == 0) {
        await loadInitFreeData();
        docFutureList = docFreeList;
      } else if (selectedButtonIndex == 2) {
        await loadInitHotData();
        docFutureList = docHotList;
      }
    } else {
      final secondsLeft = 5 - now.difference(lastRefreshTime!).inSeconds;
      ErrorGetxToast.show(
        context,
        '새로고침 대기',
        '$secondsLeft초 후에 다시 새로고침 해주세요',
      );
    }
  }

  Future<void> getUserStateSpace() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(authUid)
        .collection('userState')
        .doc(authUid)
        .get();

    UserStateModel data = UserStateModel.fromJson(
      documentSnapshot.data() as Map<String, dynamic>,
    );

    userStateDocument = documentSnapshot;

    if (documentSnapshot.exists && data.spaceState == '3') {
      setState(() {
        isUnable = true;
      });
    }
  }

  Future<void> loadInitFreeData() async {
    docFreeList = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('space')
        .where('category', isEqualTo: 'free')
        .where('reportState', isEqualTo: 'able')
        .orderBy('createdAt', descending: true)
        .limit(15)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        docFreeList.add(doc);
      }
      setState(() {
        lastFreeDocument = docFreeList.last;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadMoreFreeData() async {
    if (isMoreLoading || totalLoadedFreeDataCount >= 500) return;
    setState(() {
      isMoreLoading = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('space')
        .where('category', isEqualTo: 'free')
        .where('reportState', isEqualTo: 'able')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastFreeDocument!)
        .limit(3)
        .get();

    List<DocumentSnapshot> newDocuments = querySnapshot.docs;
    if (newDocuments.isEmpty) {
      hasMoreData = false;
    } else {
      lastFreeDocument = newDocuments.last;
      docFreeList.addAll(newDocuments);
      totalLoadedFreeDataCount += newDocuments.length;
    }
    setState(() {
      isMoreLoading = false;
    });
  }

  Future<void> loadInitHotData() async {
    docHotList = [];

    DateTime twoMonthAgo = DateTime.now().subtract(Duration(days: 60));

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('space')
        .where('reportState', isEqualTo: 'able')
        .orderBy('likeCount', descending: true)
        .limit(15)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        DateTime docCreatedAt = doc.get('createdAt').toDate();
        if (docCreatedAt.isAfter(twoMonthAgo)) {
          docHotList.add(doc);
        }
      }
      if (docHotList.isNotEmpty) {
        setState(() {
          lastHotDocument = docHotList.last;
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadMoreHotData() async {
    DateTime twoMonthAgo = DateTime.now().subtract(Duration(days: 60));

    if (isMoreLoading || totalLoadedHotDataCount >= 50) return;
    setState(() {
      isMoreLoading = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('space')
        .where('reportState', isEqualTo: 'able')
        .orderBy('likeCount', descending: true)
        .startAfterDocument(lastHotDocument!)
        .limit(3)
        .get();

    List<DocumentSnapshot> newDocuments = querySnapshot.docs;
    if (newDocuments.isEmpty) {
      hasMoreData = false;
    } else {
      for (var doc in newDocuments) {
        DateTime docCreatedAt = doc.get('createdAt').toDate();
        if (docCreatedAt.isAfter(twoMonthAgo)) {
          docHotList.add(doc);
        }
      }
      totalLoadedHotDataCount += newDocuments.length;
      lastHotDocument = docHotList.last;
    }
    setState(() {
      isMoreLoading = false;
    });
  }

  Future<void> reloadOneFreePostData(String docId) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('space').doc(docId).get();

    if (documentSnapshot.exists) {
      var updatedPost = documentSnapshot;

      int indexToUpdate = docFreeList.indexWhere((doc) => doc.id == docId);
      if (indexToUpdate != -1) {
        setState(() {
          docFreeList[indexToUpdate] = updatedPost;
        });
      }
    }
  }

  Future<void> reloadOneHotPostData(String docId) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('space').doc(docId).get();

    if (documentSnapshot.exists) {
      var updatedPost = documentSnapshot;

      int indexToUpdate = docHotList.indexWhere((doc) => doc.id == docId);
      if (indexToUpdate != -1) {
        setState(() {
          docHotList[indexToUpdate] = updatedPost;
        });
      }
    }
  }

  Future<void> loadUserBlock() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? blockedListJson = prefs.getString('SpaceUserBlockList');
    List<String> blockedList = [];
    if (blockedListJson != null) {
      blockedList = List<String>.from(json.decode(blockedListJson));
    }

    setState(() {
      userBlockList = blockedList;
    });
  }

  Future<void> cancelUserBlock(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? blockedListJson = prefs.getString('SpaceUserBlockList');
    List<String> blockedList = [];
    if (blockedListJson != null) {
      blockedList = List<String>.from(json.decode(blockedListJson));
    }

    blockedList.remove(uid);
    await prefs.setString('SpaceUserBlockList', json.encode(blockedList));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: MainAppBar(
            title: '스페이스',
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: () {
                    Get.to(() => SpaceMy(
                          rank1Uid: widget.rank1Uid,
                          rank2Uid: widget.rank2Uid,
                          rank3Uid: widget.rank3Uid,
                        ));
                  },
                  icon: SvgPicture.asset(
                    'asset/svg/space_profile.svg',
                    height: 30,
                  ),
                ),
              ),
            ],
            textStyle: font25w800.copyWith(
              color: Colors.black,
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: List.generate(
                            3,
                            (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (index == 1) {
                                      InfoGetxToast.show(context, '학습자료 준비중',
                                          '열심히 개발중이에요. 조금만 기다려주세요!');
                                    } else {
                                      selectedButtonIndex = index;
                                    }

                                    switch (selectedButtonIndex) {
                                      case 0:
                                        docFutureList = docFreeList;
                                        break;
                                      case 1:
                                        docFutureList = docStudyList;
                                        break;
                                      case 2:
                                        docFutureList = docHotList;
                                        break;
                                      default:
                                        docFutureList = docFreeList;
                                    }
                                  });
                                },
                                child: StateButtonFirst(
                                  widgetText: buttonTexts[index],
                                  isSelected: selectedButtonIndex == index,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => SpaceSearch(
                                rank1Uid: widget.rank1Uid,
                                rank2Uid: widget.rank2Uid,
                                rank3Uid: widget.rank3Uid,
                              ));
                        },
                        child: SvgPicture.asset(
                          'asset/svg/space_search.svg',
                          height: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomMaterialIndicator(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  onRefresh: onRefresh,
                  indicatorBuilder: (context, controller) {
                    return Lottie.asset(
                      'asset/lottie/short_loading_first_animation.json',
                      height: 100,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: ScrollConfiguration(
                      behavior: NoGlowScrollBehavior(),
                      child: ListView.separated(
                        controller: scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot spaceSnapshot = docFutureList[index];

                          SpaceModel data = SpaceModel.fromJson(
                            spaceSnapshot.data() as Map<String, dynamic>,
                          );

                          if (userBlockList.contains(data.uid)) {
                            return Container(
                              height: 50,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Icon(
                                      Icons.block_rounded,
                                      size: 25,
                                      color: camelColor,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      '차단한 사용자의 글이에요',
                                      style: font15w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      await cancelUserBlock(data.uid);
                                      await loadUserBlock();
                                    },
                                    child: Text(
                                      '해제',
                                      style: font13w400.copyWith(
                                        color: greyColorDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

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
                                    likeUids: data.likeUids ?? [],
                                    uid: data.uid,
                                    rank1Uid: widget.rank1Uid,
                                    rank2Uid: widget.rank2Uid,
                                    rank3Uid: widget.rank3Uid,
                                  ),
                                )!
                                    .then((_) {
                                  if (selectedButtonIndex == 0) {
                                    reloadOneFreePostData(data.docId);
                                  } else if (selectedButtonIndex == 2) {
                                    reloadOneHotPostData(data.docId);
                                  }
                                  loadUserBlock();
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
                        itemCount: docFutureList.length,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (userStateDocument != null) {
                Get.to(
                  () => SpaceWriting(
                    category: selectedButtonIndex == 0 ? 'free' : 'free',
                    userStateDocument: userStateDocument!,
                  ),
                );
              }
            },
            elevation: 5,
            backgroundColor: mainColor,
            shape: CircleBorder(),
            child: SvgPicture.asset(
              'asset/svg/space_writing.svg',
              height: 30,
              color: Colors.white,
            ),
          ),
        ),
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
                            '스페이스 이용 제한 안내',
                            style: font18w800,
                          ),
                          SizedBox(height: 10),
                          Text(
                            '커뮤니티 규정을 3번 이상 위반하여 스페이스를 잠시 이용할 수 없어요. 다시 이용을 원할 경우 고객센터로 직접 문의해주세요.',
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
    );
  }
}
