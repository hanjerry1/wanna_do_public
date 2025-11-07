import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';
import 'package:webview_flutter/webview_flutter.dart';

final homeUrl1 = Uri.parse(
    'https://marvelous-cantaloupe-01b.notion.site/ebfe5d06b7d641d7b62f9fe0456f013b?pvs=4');
final homeUrl2 = Uri.parse(
    'https://marvelous-cantaloupe-01b.notion.site/82dde54db7de4131ab4328fc33fb56be?pvs=4');
final homeUrl3 = Uri.parse(
    'https://marvelous-cantaloupe-01b.notion.site/058f6cfd334647fcb7785aaf8986bb89?pvs=4');

class RoleHome extends StatefulWidget {
  const RoleHome({super.key});

  @override
  State<RoleHome> createState() => _RoleHomeState();
}

class _RoleHomeState extends State<RoleHome> {
  WebViewController controller1 = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(homeUrl1);

  WebViewController controller2 = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(homeUrl2);

  WebViewController controller3 = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(homeUrl3);
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: SubAppBar(
            title: '규정',
          ),
          body: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: '챌린지'),
                  Tab(text: '체크업'),
                  Tab(text: '스페이스'),
                ],
                labelColor: charcoalColor,
                labelStyle: font18w800.copyWith(fontFamily: 'NanumSquare'),
                unselectedLabelColor: charcoalColor.withOpacity(0.3),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 2,
                    color: charcoalColor,
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        WebViewWidget(
                          controller: controller1,
                        ),
                        WebViewWidget(
                          controller: controller2,
                        ),
                        WebViewWidget(
                          controller: controller3,
                        ),
                      ],
                    ),
                    if (isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white,
                          child: Center(
                            child: Lottie.asset(
                              'asset/lottie/short_loading_first_animation.json',
                              height: 100,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
