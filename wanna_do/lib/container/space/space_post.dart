import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wanna_do/component/main_page.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/help/report_home.dart';
import 'package:wanna_do/container/public/image_viewer.dart';
import 'package:wanna_do/controller/page/main_page_controller.dart';
import 'package:wanna_do/model/space/chat_model.dart';
import 'package:wanna_do/model/space/space_model.dart';
import 'package:wanna_do/model/user/user_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/dialog_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class SpacePost extends StatefulWidget {
  final String docId;
  final String uid;
  final String title;
  final String content;
  final String nickname;
  final String rank1Uid;
  final String rank2Uid;
  final String rank3Uid;
  final bool isUnknown;
  final int likeCount;
  final int chatCount;
  final DateTime createdAt;
  final DateTime? editAt;
  final List<String> postUrl;
  final List<String> likeUids;

  const SpacePost({
    super.key,
    required this.docId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isUnknown,
    required this.nickname,
    required this.likeCount,
    required this.chatCount,
    required this.postUrl,
    required this.likeUids,
    required this.uid,
    this.editAt,
    required this.rank1Uid,
    required this.rank2Uid,
    required this.rank3Uid,
  });

  @override
  State<SpacePost> createState() => _SpacePostState();
}

class _SpacePostState extends State<SpacePost>
    with SingleTickerProviderStateMixin {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController textEditingController = TextEditingController();
  ScrollController scrollController = ScrollController();
  late AnimationController animationController;
  List<DocumentSnapshot> docFutureList = [];
  List<String> myLikeChatList = [];
  DateTime? lastSendTime;
  bool isHeart = false;
  bool isUnknown = true;
  bool isLoading = false;
  bool isBlock = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    checkMyLike();
  }

  @override
  void dispose() {
    animationController.dispose();
    textEditingController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void checkMyLike() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('space')
          .doc(widget.docId)
          .get();

      SpaceModel data = SpaceModel.fromJson(
        documentSnapshot.data() as Map<String, dynamic>,
      );

      if (data.likeUids!.contains(authUid)) {
        setState(() {
          animationController.forward();
          isHeart = true;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<List<DocumentSnapshot>> loadChatAndCheckMyLike(String docId) async {
    List<DocumentSnapshot> docTotalList = [];
    List<String> myLikeChatLists = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('space')
        .doc(docId)
        .collection('chat')
        .orderBy('createdAt', descending: false)
        .get();

    for (var doc in querySnapshot.docs) {
      docTotalList.add(doc);
      ChatModel data = ChatModel.fromJson(
        doc.data() as Map<String, dynamic>,
      );

      if (data.likeUids!.contains(authUid)) {
        myLikeChatLists.add(data.docId);
      }
    }

    myLikeChatList = myLikeChatLists;
    return docTotalList;
  }

  Future<void> sendChat() async {
    try {
      setState(() {
        isLoading = true;
      });
      FocusScope.of(context).unfocus();

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(authUid)
          .get();

      UserModel userData = UserModel.fromJson(
        userSnapshot.data() as Map<String, dynamic>,
      );

      DocumentSnapshot spaceSnapshot = await FirebaseFirestore.instance
          .collection('space')
          .doc(widget.docId)
          .get();

      if (!spaceSnapshot.exists) {
        Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
          Get.put(MainPageController(initialTabIndex: 2));
        }));
        ErrorGetxToast.show(context, '게시글 삭제', '해당 게시글이 삭제되었어요');
        return;
      }

      SpaceModel spaceData = SpaceModel.fromJson(
        spaceSnapshot.data() as Map<String, dynamic>,
      );

      List<String> chatUids = spaceData.chatUids ?? [];

      if (spaceData.isUnknown) {
        if (!chatUids.contains(authUid)) {
          chatUids.add(authUid);
        }
      }

      String unKnownName = '익명${chatUids.indexOf(authUid) + 1}';

      var chatDocId = FirebaseFirestore.instance
          .collection('space')
          .doc(widget.docId)
          .collection('chat')
          .doc()
          .id;

      ChatModel chatModel = ChatModel(
        uid: authUid,
        nickname: userData.nickname!,
        content: textEditingController.text,
        reportState: 'able',
        isUnknown: isUnknown,
        docId: chatDocId,
        likeCount: 0,
        unKnownName: unKnownName,
      );

      WriteBatch batch = FirebaseFirestore.instance.batch();

      DocumentReference chatRef = FirebaseFirestore.instance
          .collection('space')
          .doc(widget.docId)
          .collection('chat')
          .doc(chatDocId);

      DocumentReference spaceRef =
          FirebaseFirestore.instance.collection('space').doc(widget.docId);

      batch.set(chatRef, chatModel.toJson());

      batch.update(spaceRef, {
        'chatCount': FieldValue.increment(1),
        'chatUids': chatUids,
      });

      await batch.commit();

      setState(() {
        isLoading = false;
      });

      textEditingController.clear();
      Future.delayed(Duration(milliseconds: 500), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> deleteMyPost() async {
    try {
      setState(() {
        isLoading = true;
      });

      String deviceId = '';
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
        deviceId = iosInfo.identifierForVendor!;
      }

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(authUid)
          .get();

      UserModel data = UserModel.fromJson(
        documentSnapshot.data() as Map<String, dynamic>,
      );

      if (data.deviceId != deviceId) {
        Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
          Get.put(MainPageController(initialTabIndex: 2));
        }));
        ErrorGetxToast.show(context, '앱을 재시작 해주세요', '앱에서 하나의 기기만 사용해주세요');
        return;
      }

      FirebaseStorage storage = FirebaseStorage.instance;
      if (widget.postUrl.isNotEmpty) {
        for (String url in widget.postUrl) {
          Reference ref = storage.refFromURL(url);
          await ref.delete();
        }
      }

      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference documentRef =
            FirebaseFirestore.instance.collection('space').doc(widget.docId);
        DocumentReference statisticMyRef =
            FirebaseFirestore.instance.collection('statistic').doc(authUid);

        QuerySnapshot chatSnapshot = await FirebaseFirestore.instance
            .collection('space')
            .doc(widget.docId)
            .collection('chat')
            .get();

        for (DocumentSnapshot chatDoc in chatSnapshot.docs) {
          transaction.delete(chatDoc.reference);
        }

        for (String uid in widget.likeUids) {
          DocumentReference statisticRef =
              FirebaseFirestore.instance.collection('statistic').doc(uid);
          transaction.update(
            statisticRef,
            {'totalMyLikePost': FieldValue.increment(-1)},
          );
        }

        transaction.update(
          statisticMyRef,
          {
            'totalMyPost': FieldValue.increment(-1),
            'monthMyPost': FieldValue.increment(-1),
          },
        );

        transaction.delete(documentRef);
      }).then((result) async {
        Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
          Get.put(MainPageController(initialTabIndex: 2));
          InfoGetxToast.show(context, '게시물 삭제 완료', '글을 깔끔하게 삭제했어요');
        }));
      }).catchError((e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> postLikeOn() async {
    try {
      setState(() {
        isLoading = true;
      });

      String deviceId = '';
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
        deviceId = iosInfo.identifierForVendor!;
      }

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(authUid)
          .get();

      UserModel data = UserModel.fromJson(
        documentSnapshot.data() as Map<String, dynamic>,
      );

      if (data.deviceId != deviceId) {
        Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
          Get.put(MainPageController(initialTabIndex: 2));
        }));
        ErrorGetxToast.show(context, '앱을 재시작 해주세요', '앱에서 하나의 기기만 사용해주세요');
        return;
      }

      DocumentSnapshot spaceSnapshot = await FirebaseFirestore.instance
          .collection('space')
          .doc(widget.docId)
          .get();

      if (!spaceSnapshot.exists) {
        Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
          Get.put(MainPageController(initialTabIndex: 2));
        }));
        ErrorGetxToast.show(context, '게시글 삭제', '해당 게시글이 삭제되었어요');
        return;
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();

      DocumentReference statisticRef =
          FirebaseFirestore.instance.collection('statistic').doc(authUid);

      DocumentReference spaceRef =
          FirebaseFirestore.instance.collection('space').doc(widget.docId);

      batch.update(statisticRef, {'totalMyLikePost': FieldValue.increment(1)});

      batch.update(spaceRef, {
        'likeCount': FieldValue.increment(1),
        'likeUids': FieldValue.arrayUnion([authUid])
      });

      await batch.commit();

      setState(() {
        animationController.forward();
        isHeart = !isHeart;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> postLikeOff() async {
    try {
      setState(() {
        isLoading = true;
      });

      String deviceId = '';
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
        deviceId = iosInfo.identifierForVendor!;
      }

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(authUid)
          .get();

      UserModel data = UserModel.fromJson(
        documentSnapshot.data() as Map<String, dynamic>,
      );

      if (data.deviceId != deviceId) {
        Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
          Get.put(MainPageController(initialTabIndex: 2));
        }));
        ErrorGetxToast.show(context, '앱을 재시작 해주세요', '앱에서 하나의 기기만 사용해주세요');
        return;
      }

      DocumentSnapshot spaceSnapshot = await FirebaseFirestore.instance
          .collection('space')
          .doc(widget.docId)
          .get();

      if (!spaceSnapshot.exists) {
        Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
          Get.put(MainPageController(initialTabIndex: 2));
        }));
        ErrorGetxToast.show(context, '게시글 삭제', '해당 게시글이 삭제되었어요');
        return;
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();

      DocumentReference statisticRef =
          FirebaseFirestore.instance.collection('statistic').doc(authUid);

      DocumentReference spaceRef =
          FirebaseFirestore.instance.collection('space').doc(widget.docId);

      batch.update(statisticRef, {'totalMyLikePost': FieldValue.increment(-1)});

      batch.update(spaceRef, {
        'likeCount': FieldValue.increment(-1),
        'likeUids': FieldValue.arrayRemove([authUid])
      });

      await batch.commit();

      setState(() {
        isHeart = !isHeart;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> chatLikeOn(ChatModel data) async {
    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('space')
          .doc(widget.docId)
          .collection('chat')
          .doc(data.docId)
          .update({
        'likeCount': FieldValue.increment(1),
        'likeUids': FieldValue.arrayUnion([authUid])
      });

      setState(() {
        myLikeChatList.add(data.docId);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> chatLikeOff(ChatModel data) async {
    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('space')
          .doc(widget.docId)
          .collection('chat')
          .doc(data.docId)
          .update({
        'likeCount': FieldValue.increment(-1),
        'likeUids': FieldValue.arrayRemove([authUid]),
      });

      setState(() {
        myLikeChatList.remove(data.docId);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> addUserBlock() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? blockedListJson = prefs.getString('SpaceUserBlockList');
    List<String> blockedList = [];
    if (blockedListJson != null) {
      blockedList = List<String>.from(json.decode(blockedListJson));
    }

    if (blockedList.contains(widget.uid)) {
      ErrorGetxToast.show(context, '사용자 차단 알림', '이미 차단한 사용자에요');
      return;
    }

    blockedList.add(widget.uid);
    await prefs.setString('SpaceUserBlockList', json.encode(blockedList));
    InfoGetxToast.show(context, '사용자 차단 완료', '더 큰 문제가 있다면 신고도 부탁드려요');
  }

  Future<void> remoteConfigLogin() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    try {
      await remoteConfig.fetchAndActivate();
      isBlock = remoteConfig.getBool('isBlock');
      return;
    } catch (exception) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SubAppBar(
          title: '자유',
          actions: [
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert_rounded,
                color: Colors.black,
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.black.withOpacity(0.6),
                        size: 22,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '신고하기',
                        style: font16w700.copyWith(
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isBlock && widget.uid != authUid && widget.uid != 'none')
                  PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        Icon(
                          Icons.block_rounded,
                          color: Colors.black.withOpacity(0.6),
                          size: 22,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '차단하기',
                          style: font16w700.copyWith(
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (widget.uid == authUid)
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.close_outlined,
                          color: Colors.black.withOpacity(0.6),
                          size: 22,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '글 삭제하기',
                          style: font16w700.copyWith(
                            color: Colors.black.withOpacity(0.6),
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
                      postId: widget.docId,
                      uid: widget.uid,
                      title: widget.title,
                      content: widget.content,
                      postAt: widget.createdAt,
                    ),
                  );
                } else if (result == 'delete') {
                  Get.dialog(
                    DialogTwoButton(
                      title: '내 게시글 삭제하기',
                      content: Text(
                        '게시글을 삭제하면 되돌릴 수 없어요. 그래도 정말 삭제할까요?',
                        style: font15w700,
                      ),
                      leftText: '취소',
                      rightText: '삭제하기',
                      onLeftButtonPressed: () {
                        Get.back();
                      },
                      onRightButtonPressed: () async {
                        await deleteMyPost();
                      },
                    ),
                  );
                } else if (result == 'block') {
                  Get.dialog(
                    DialogTwoButton(
                      title: '차단하기',
                      content: Text(
                        '차단하면 앞으로 이 사용자의 글 내용을 더이상 볼 수 없어요. 차단할까요?',
                        style: font15w700,
                      ),
                      leftText: '취소',
                      rightText: '차단하기',
                      onLeftButtonPressed: () {
                        Get.back();
                      },
                      onRightButtonPressed: () async {
                        Get.back();
                        await addUserBlock();
                      },
                    ),
                  );
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 1,
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: NoGlowScrollBehavior(),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                if (widget.uid == authUid)
                                  Row(
                                    children: [
                                      Text(
                                        'me',
                                        style: font15w700.copyWith(
                                            color: orangeColor),
                                      ),
                                      SizedBox(width: 5),
                                    ],
                                  ),
                                Row(
                                  children: [
                                    Text(
                                      widget.isUnknown ? '익명' : widget.nickname,
                                      style: font16w700,
                                    ),
                                    SizedBox(width: 5),
                                    if (widget.uid == widget.rank1Uid)
                                      Image.asset(
                                        'asset/img/medal_first.png',
                                        height: 15,
                                      ),
                                    if (widget.uid == widget.rank2Uid)
                                      Image.asset(
                                        'asset/img/medal_second.png',
                                        height: 15,
                                      ),
                                    if (widget.uid == widget.rank3Uid)
                                      Image.asset(
                                        'asset/img/medal_third.png',
                                        height: 15,
                                      ),
                                  ],
                                ),
                                Text(
                                  ' · ',
                                  style: font18w700,
                                ),
                                Text(
                                  DateFormatUtilsSixth.formatDay(
                                      widget.createdAt),
                                  style: font15w700.copyWith(
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              widget.title,
                              style: font18w800,
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              widget.content,
                              style: font15w400,
                            ),
                          ),
                          if (widget.postUrl.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Column(
                                children: [
                                  SizedBox(height: 40),
                                  Container(
                                    height: 200,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: widget.postUrl.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          height: 200,
                                          width: 200,
                                          child: GestureDetector(
                                            onTap: () {
                                              Get.to(
                                                () => ImageViewer(
                                                  imageList: widget.postUrl,
                                                  initialIndex: index,
                                                ),
                                              );
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                              child: CachedNetworkImage(
                                                imageUrl: widget.postUrl[index],
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
                                                      '저장기간 경과',
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
                                          ),
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return SizedBox(width: 10);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 30),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('space')
                                          .doc(widget.docId)
                                          .get(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Container();
                                        }

                                        SpaceModel data = SpaceModel.fromJson(
                                          snapshot.data!.data()
                                              as Map<String, dynamic>,
                                        );

                                        return Row(
                                          children: [
                                            SvgPicture.asset(
                                              'asset/svg/space_heart.svg',
                                              height: 20,
                                              color: subColorDark,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              data.likeCount.toString(),
                                              style: font18w800.copyWith(
                                                color: subColorDark,
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            SvgPicture.asset(
                                              'asset/svg/space_chat.svg',
                                              height: 20,
                                              color: mainColor,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              data.chatCount.toString(),
                                              style: font18w800.copyWith(
                                                color: mainColor,
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                                if (!isHeart)
                                  GestureDetector(
                                    onTap: () async {
                                      await postLikeOn();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: greyColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'asset/svg/space_heart.svg',
                                              height: 20,
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              '좋아요',
                                              style: font15w700.copyWith(
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                if (isHeart)
                                  GestureDetector(
                                    onTap: () async {
                                      await postLikeOff();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: ScaleTransition(
                                          scale: Tween<double>(
                                                  begin: 0.1, end: 1.0)
                                              .animate(animationController),
                                          child: SvgPicture.asset(
                                            'asset/svg/heart.svg',
                                            height: 20,
                                            color: redColor,
                                          ),
                                        ),
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
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: FutureBuilder<List<DocumentSnapshot>>(
                              future: loadChatAndCheckMyLike(widget.docId),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Column(
                                    children: [
                                      SizedBox(height: 50),
                                      Center(
                                        child: Lottie.asset(
                                          'asset/lottie/short_loading_first_animation.json',
                                          height: 50,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                docFutureList = snapshot.data!;

                                return Container(
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      DocumentSnapshot documentSnapshot =
                                          docFutureList[index];

                                      ChatModel data = ChatModel.fromJson(
                                        documentSnapshot.data()
                                            as Map<String, dynamic>,
                                      );

                                      if (data.reportState == 'unable') {
                                        return Container(
                                          height: 60,
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.error_outlined,
                                                    size: 25,
                                                    color: camelColor,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    '부적절한 내용으로 삭제된 댓글이에요',
                                                    style: font15w700.copyWith(
                                                      color: charcoalColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    if (data.uid == authUid)
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'me',
                                                            style: font15w700
                                                                .copyWith(
                                                                    color:
                                                                        orangeColor),
                                                          ),
                                                          SizedBox(width: 5),
                                                        ],
                                                      ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          data.isUnknown
                                                              ? widget.uid ==
                                                                      data.uid
                                                                  ? '익명'
                                                                  : data
                                                                      .unKnownName
                                                              : data.nickname,
                                                          style: font15w700,
                                                        ),
                                                        SizedBox(width: 5),
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
                                                    Text(
                                                      ' · ',
                                                      style: font15w700,
                                                    ),
                                                    Text(
                                                      data.createdAt != null
                                                          ? DateFormatUtilsSixth
                                                              .formatDay(data
                                                                  .createdAt!
                                                                  .toDate())
                                                          : '',
                                                      style:
                                                          font13w700.copyWith(
                                                        color: Colors.black
                                                            .withOpacity(0.6),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuButton(
                                                icon: Icon(
                                                  Icons.more_vert_rounded,
                                                  color: Colors.black,
                                                ),
                                                itemBuilder: (BuildContext
                                                        context) =>
                                                    <PopupMenuEntry<String>>[
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
                                                          style: font16w700
                                                              .copyWith(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.6),
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
                                                        chat: data.content,
                                                        postId: widget.docId,
                                                        chatId: data.docId,
                                                        uid: data.uid,
                                                        content: widget.content,
                                                        title: widget.title,
                                                        postAt: data.createdAt!
                                                            .toDate(),
                                                      ),
                                                    );
                                                  }
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                elevation: 1,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                data.isUnknown
                                                    ? '익명'
                                                    : data.nickname,
                                                style: font15w700.copyWith(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                ' · ',
                                                style: font15w700.copyWith(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  data.content,
                                                  style: font15w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'asset/svg/space_heart.svg',
                                                      height: 20,
                                                      color: subColorDark,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      data.likeCount.toString(),
                                                      style:
                                                          font15w800.copyWith(
                                                        color: subColorDark,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (!myLikeChatList
                                                  .contains(data.docId))
                                                GestureDetector(
                                                  onTap: () async {
                                                    await chatLikeOn(data);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: greyColor
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Row(
                                                        children: [
                                                          SvgPicture.asset(
                                                            'asset/svg/space_heart.svg',
                                                            height: 15,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.6),
                                                          ),
                                                          SizedBox(width: 5),
                                                          Text(
                                                            '좋아요',
                                                            style: font13w700
                                                                .copyWith(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.6),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              if (myLikeChatList
                                                  .contains(data.docId))
                                                GestureDetector(
                                                  onTap: () async {
                                                    await chatLikeOff(data);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: SvgPicture.asset(
                                                        'asset/svg/heart.svg',
                                                        height: 15,
                                                        color: redColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return Divider(
                                        thickness: 0.3,
                                      );
                                    },
                                    itemCount: docFutureList.length,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: greyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          width: 1,
                          color: greyColor.withOpacity(0.3),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isUnknown = !isUnknown;
                                });
                              },
                              child: Row(
                                children: [
                                  Image.asset(
                                    'asset/img/check_mini2.png',
                                    color: isUnknown ? mainColor : greyColor,
                                    height: 15,
                                  ),
                                  SizedBox(width: 5),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: Text(
                                      '익명',
                                      style: font15w700.copyWith(
                                        color: isUnknown
                                            ? Colors.black
                                            : greyColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 2.0),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: '댓글을 작성해보세요',
                                    hintStyle: font18w400,
                                    counterText: '',
                                    border: InputBorder.none,
                                  ),
                                  controller: textEditingController,
                                  onChanged: (String? val) {
                                    setState(() {});
                                  },
                                  cursorColor: mainColor,
                                  style: font18w400,
                                  minLines: 1,
                                  maxLines: 5,
                                  maxLength: 2000,
                                  keyboardType: TextInputType.multiline,
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            GestureDetector(
                              onTap: textEditingController.text.isEmpty
                                  ? null
                                  : () async {
                                      final now = DateTime.now();
                                      if (lastSendTime == null ||
                                          now
                                                  .difference(lastSendTime!)
                                                  .inSeconds >
                                              10) {
                                        lastSendTime = now;
                                        await sendChat();
                                      } else {
                                        final secondsLeft = 10 -
                                            now
                                                .difference(lastSendTime!)
                                                .inSeconds;
                                        ErrorGetxToast.show(
                                          context,
                                          '댓글 전송 대기',
                                          '$secondsLeft초 후에 다시 작성 해주세요',
                                        );
                                      }
                                    },
                              child: Icon(
                                Icons.send_rounded,
                                size: 25,
                                color: textEditingController.text.isEmpty
                                    ? greyColor
                                    : mainColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isLoading) ShortLoadingFirst(),
          ],
        ),
      ),
    );
  }
}
