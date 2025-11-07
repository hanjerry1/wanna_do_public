import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class VideoPlay extends StatefulWidget {
  final String videoUrl;

  VideoPlay({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayState createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController customVideoPlayerController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value) => setState(() {}));
    customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: videoPlayerController,
    );
    videoPlayerController.setVolume(0.0);
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    customVideoPlayerController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:
          customVideoPlayerController.videoPlayerController.value.isInitialized
              ? SafeArea(
                  child: Center(
                    child: CustomVideoPlayer(
                      customVideoPlayerController: customVideoPlayerController,
                    ),
                  ),
                )
              : SafeArea(
                  child: Center(
                    child: Lottie.asset(
                      'asset/lottie/short_loading_first_animation.json',
                      height: 100,
                    ),
                  ),
                ),
    );
  }
}
