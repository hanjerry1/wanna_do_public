import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/public/algolia_Manager.dart';
import 'package:wanna_do/container/space/space_post.dart';
import 'package:wanna_do/model/space/space_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class SpaceSearch extends StatefulWidget {
  final String rank1Uid;
  final String rank2Uid;
  final String rank3Uid;

  SpaceSearch({
    super.key,
    required this.rank1Uid,
    required this.rank2Uid,
    required this.rank3Uid,
  });

  @override
  State<SpaceSearch> createState() => _SpaceSearchState();
}

class _SpaceSearchState extends State<SpaceSearch> {
  List<AlgoliaObjectSnapshot> searchResultsList = [];
  String searchQuery = '';

  void searchDocuments() async {
    try {
      searchResultsList = await AlgoliaManagerSpace.search(searchQuery);
      setState(() {});
    } catch (e) {
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
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
        resizeToAvoidBottomInset: false,
        appBar: SubAppBar(
          title: '검색',
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      Icon(
                        Icons.search_rounded,
                        size: 25,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: '키워드 입력',
                              hintStyle: font18w400,
                              counterText: '',
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              searchQuery = value.toLowerCase();
                            },
                            onSubmitted: (value) {
                              searchDocuments();
                            },
                            cursorColor: mainColor,
                            style: font18w400,
                            maxLines: 1,
                            maxLength: 100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (searchResultsList.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'asset/lottie/wanna_do_checker_animation.json',
                      height: 250,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '아직 찾은 데이터가 없어요',
                      style: font15w400,
                    ),
                  ],
                ),
              ),
            if (searchResultsList.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ScrollConfiguration(
                    behavior: NoGlowScrollBehavior(),
                    child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        AlgoliaObjectSnapshot spaceSnapshot =
                            searchResultsList[index];

                        SpaceModel data = SpaceModel.fromJson(
                          spaceSnapshot.data,
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
                              );
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
                                          color: Colors.black.withOpacity(0.5),
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
                                                if (data.uid == widget.rank1Uid)
                                                  Image.asset(
                                                    'asset/img/medal_first.png',
                                                    height: 15,
                                                  ),
                                                if (data.uid == widget.rank2Uid)
                                                  Image.asset(
                                                    'asset/img/medal_second.png',
                                                    height: 15,
                                                  ),
                                                if (data.uid == widget.rank3Uid)
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
                                                    style: font15w800.copyWith(
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
                                                    style: font15w800.copyWith(
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
                      itemCount: searchResultsList.length,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
