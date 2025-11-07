import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wanna_do/component/main_page.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/manage/container/manage_main_first.dart';
import 'package:wanna_do/manage/container/manage_main_fourth.dart';
import 'package:wanna_do/manage/container/manage_main_second.dart';
import 'package:wanna_do/manage/container/manage_main_third.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ManageMainPage extends StatefulWidget {
  final int currentIndex;

  ManageMainPage({
    super.key,
    this.currentIndex = 0,
  });

  @override
  State<ManageMainPage> createState() => _ManageMainPageState();
}

class _ManageMainPageState extends State<ManageMainPage>
    with TickerProviderStateMixin {
  late TabController tabController;

  final List<Map<String, dynamic>> tabs = [
    {
      'icon': 'asset/svg/home_icon.svg',
      'activeIcon': 'asset/svg/home_icon_fill.svg',
      'label': '챌린지 관리',
    },
    {
      'icon': 'asset/svg/checkup_icon.svg',
      'activeIcon': 'asset/svg/checkup_icon_fill.svg',
      'label': '사용자 관리',
    },
    {
      'icon': 'asset/svg/space_icon.svg',
      'activeIcon': 'asset/svg/space_icon_fill.svg',
      'label': '출금 관리',
    },
    {
      'icon': 'asset/svg/my_icon.svg',
      'activeIcon': 'asset/svg/my_icon_fill.svg',
      'label': '기타 관리',
    },
  ];

  @override
  void initState() {
    super.initState();
    tabController = FastTabController(
      length: 4,
      vsync: this,
    );
    tabController.index = widget.currentIndex;
    tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: MainAppBar(
          title: 'Wanna Do 관리자 전용',
          textStyle: font18w700.copyWith(
            color: Colors.black,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => MainPage());
                },
                child: Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      Center(
                        child: Text(
                          '워너두 메인',
                          style: font16w800.copyWith(
                            color: mainColor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: mainColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: TabBarView(
          controller: tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ManageMainFirst(),
            ManageMainSecond(),
            ManageMainThird(),
            ManageMainFourth(),
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Color(0xF5FFFFFF),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            elevation: 10,
            currentIndex: tabController.index,
            onTap: (index) {
              setState(() {
                tabController.index = index;
              });
            },
            selectedItemColor: Colors.black,
            selectedLabelStyle: font13w700,
            unselectedItemColor: Colors.black.withOpacity(0.5),
            unselectedLabelStyle: font13w400,
            items: tabs.map((tab) {
              return BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: SvgPicture.asset(
                    tab['icon'] as String,
                    height: 25,
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: SvgPicture.asset(
                    tab['activeIcon'] as String,
                    height: 25,
                  ),
                ),
                label: tab['label'] as String,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
