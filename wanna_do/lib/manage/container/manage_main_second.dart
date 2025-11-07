import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/public/algolia_Manager.dart';
import 'package:wanna_do/manage/container/user/user_manage.dart';
import 'package:wanna_do/manage/container/user/user_manage_info.dart';
import 'package:wanna_do/model/user/user_model.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ManageMainSecond extends StatefulWidget {
  const ManageMainSecond({super.key});

  @override
  _ManageMainSecondState createState() => _ManageMainSecondState();
}

class _ManageMainSecondState extends State<ManageMainSecond>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<AlgoliaObjectSnapshot> searchResultsList = [];
  String searchQuery = '';

  void searchDocuments() async {
    try {
      searchResultsList = await AlgoliaManagerUserManage.search(searchQuery);
      setState(() {});
    } catch (e) {
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '유저 관리',
            style: font23w800,
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
        SizedBox(height: 10),
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
                  AlgoliaObjectSnapshot userSnapshot = searchResultsList[index];

                  UserModel data = UserModel.fromJson(
                    userSnapshot.data,
                  );

                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'uid: ${data.uid}',
                                    style: font16w700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'name: ${data.name}',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'email: ${data.email}',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                      '가입일: ${data.createdAt!.toDate().toString()}'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        children: [
                          SmallButtonFirst(
                            onPressed: () {
                              Get.to(
                                () => UserManage(
                                  uid: data.uid,
                                ),
                              );
                            },
                            backgroundColor: mainColor,
                            content: Text(
                              '유저 관리',
                              style: font15w700.copyWith(color: Colors.white),
                            ),
                          ),
                          SmallButtonFirst(
                            onPressed: () {
                              Get.to(
                                () => UserManageInfo(
                                  uid: data.uid,
                                ),
                              );
                            },
                            backgroundColor: orangeColor,
                            content: Text(
                              '유저 정보',
                              style: font15w700.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
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
    );
  }
}
