import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../../common/index.dart';
import '../../mixins/index.dart';

class _Boot extends State<Boot> with Standby {
  final videoPlayerController =
      VideoPlayerController.asset('assets/video/boot.mp4');

  ChewieController? chewieController;

  // 标志视频是否已经播放放完成
  bool hasVideoEnd = false;

  get isSupportVideo => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    debugPrint('boot-initState');
    if (isSupportVideo) {
      initVideo();
    }

    checkLogin();
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
              : const CircularProgressIndicator(),
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

  /// 检查是否已经登录
  Future checkLogin() async {
    if (Global.isLogin) {
      await UserApi.autoLogin();

      await UserApi.authToken();
    }

    if (!isSupportVideo) {
      Timer(const Duration(seconds: 2), () {
        bootFinish();
      });
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
    // 因为视频监听事件会返回2次视频结束事件，需要过滤第二次的，否则会执行bootFinish
    if (!hasVideoEnd &&
        videoPlayerController.value.position ==
            videoPlayerController.value.duration) {
      // await chewieController
      //     ?.seekTo(const Duration(seconds: 1, milliseconds: 500));
      // chewieController?.play();
      debugPrint('video Ended');
      hasVideoEnd = true;
      bootFinish();
    }
  }

  /// 启动完成
  void bootFinish() {
    debugPrint('bootFinish trigger');
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
