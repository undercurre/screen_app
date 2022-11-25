import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

import '../../common/index.dart';

class _Boot extends State<Boot> {
  final videoPlayerController =
      VideoPlayerController.asset('assets/video/boot.mp4');

  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    debugPrint('boot-initState');
    // initVideo();
    //
    // checkLogin();
    if (Platform.isAndroid) {
      initVideo();
    }

    checkLogin();

    if (!Platform.isAndroid) {
      Future.delayed(Duration.zero, () {
        bootFinish();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('boot-build');
    return Column(children: [
      Expanded(
        child: Center(
          child: chewieController != null &&
                  chewieController!.videoPlayerController.value.isInitialized
              ? Material(
                  child: Chewie(
                  controller: chewieController!,
                ))
              : Container(),
        ),
      )
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
    chewieController?.dispose();
  }

  Future checkLogin() async {
    if (Global.isLogin) {
      await UserApi.autoLogin();

      await UserApi.authToken();
    }
  }

  void initVideo() async {
    videoPlayerController.addListener(checkVideo);

    await videoPlayerController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoInitialize: false,
      autoPlay: true,
      looping: false,
      fullScreenByDefault: true,
      hideControlsTimer: const Duration(seconds: 5),
      showControls: false,
    );

    setState(() {});
  }

  /// 检查视频是否播放完毕
  void checkVideo() {
    if (videoPlayerController.value.position ==
        videoPlayerController.value.duration) {
      // await chewieController
      //     ?.seekTo(const Duration(seconds: 1, milliseconds: 500));
      // chewieController?.play();
      debugPrint('video Ended');
      bootFinish();
    }
  }

  /// 启动完成
  void bootFinish() {
    if (Global.isLogin) {}
    Navigator.pushNamed(
      context,
      'Login',
    );
  }
}

class Boot extends StatefulWidget {
  const Boot({super.key});

  @override
  State<Boot> createState() => _Boot();
}
