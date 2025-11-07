import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';
import 'package:webview_flutter/webview_flutter.dart';

final homeUrl1 =
    Uri.parse('https://www.notion.so/973825e04716464dae01adec6107783c?pvs=4');
final homeUrl2 =
    Uri.parse('https://www.notion.so/699e9027c29543d7bc4f68f874feff4d?pvs=4');

class GuideHome extends StatefulWidget {
  GuideHome({super.key});

  @override
  State<GuideHome> createState() => _GuideHomeState();
}

class _GuideHomeState extends State<GuideHome> {
  WebViewController controller1 = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(homeUrl1);

  WebViewController controller2 = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(homeUrl2);
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
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: SubAppBar(
            title: '가이드',
          ),
          body: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: '챌린지'),
                  Tab(text: '체크업'),
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
