import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ImageViewer extends StatefulWidget {
  final List<String> imageList;
  final int initialIndex;

  ImageViewer({
    required this.imageList,
    required this.initialIndex,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PageController pageController;
  int index = 0;

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex + 1;
    pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(
        title: '${index}/${widget.imageList.length}',
      ),
      body: Column(
        children: [
          Expanded(
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: PageView.builder(
                itemCount: widget.imageList.length,
                controller: pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (newIndex) {
                  setState(() {
                    index = newIndex + 1;
                  });
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: InteractiveViewer(
                      child: CachedNetworkImage(
                        imageUrl: widget.imageList[index],
                        placeholder: (context, url) => Center(
                          child: Lottie.asset(
                            'asset/lottie/short_loading_first_animation.json',
                            height: 80,
                          ),
                        ),
                        errorWidget: (context, url, error) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  if (index > 1) {
                    pageController.previousPage(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 50,
                  color: greyColorDark,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (index < widget.imageList.length) {
                    pageController.nextPage(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 50,
                  color: greyColorDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
