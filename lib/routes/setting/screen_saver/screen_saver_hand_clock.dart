import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;

import 'package:provider/provider.dart';
import 'package:screen_app/routes/setting/screen_saver/screen_saver_help.dart';

import '../../../states/standby_notifier.dart';
import 'index.dart';

class HandClockConfig {

  /// 图片资源图
  String? imgBackground;
  String imgDisc;
  String? imgSecond;
  String imgMinute;
  String imgHour;
  String imgPoint;
  /// 指针穿透圆心的距离
  int secondDistance;
  int minuteDistance;
  int hourDistance;
  Widget? widgetBg;

  HandClockConfig({
    required this.imgDisc, this.imgSecond,
    required this.imgMinute, required this.imgHour, required this.imgPoint,
    this.imgBackground,
    this.secondDistance = 20,
    this.minuteDistance = 20,
    this.hourDistance = 20,
    this.widgetBg
  });

}

class ClockStyle {

  ui.Image imgDisc;
  ui.Image? imgSecond;
  ui.Image imgMinute;
  ui.Image imgHour;
  ui.Image imgPoint;
  HandClockConfig config;

  ClockStyle({required this.imgDisc, this.imgSecond, required this.imgMinute,
    required this.imgPoint, required this.imgHour, required this.config});

}



abstract class ScreenSaverHandClock extends AbstractSaverScreen {

  const ScreenSaverHandClock({super.key});

  @override
  State<StatefulWidget> createState() => ScreenSaverHandClockState();

  HandClockConfig buildConfig();
}

class ScreenSaverHandClockState extends State<ScreenSaverHandClock> with AiWakeUPScreenSaverState {

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      widget.onTick();
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    widget.exit();
  }

  @override
  Widget build(BuildContext context) {
    final buildConfig = widget.buildConfig();
    return GestureDetector(
      onTap: () {
        Provider.of<StandbyChangeNotifier>(context, listen: false).standbyPageActive = false;
        Navigator.of(context).pop();
      },
      child: FutureBuilder<ClockStyle>(
        key: const ValueKey(1281),
        future: loadClockStyle(buildConfig),
        builder: (context, snapshot) {
          return Stack(
            alignment: Alignment.center,
            children:[
              if(buildConfig.widgetBg != null)
                  buildConfig.widgetBg!,
              if(buildConfig.imgBackground != null)
                Image.asset(buildConfig.imgBackground!),
              CustomPaint(
                size: const Size(double.infinity, double.infinity),
                painter: HandClock(snapshot.data),
              ),
            ]
          );
        }
      ),
    );
  }

  Future<ClockStyle> loadClockStyle(HandClockConfig config) async {
    final imgDisc = await loadImageByProvider(AssetImage(config.imgDisc));
    final imgMinute = await loadImageByProvider( AssetImage(config.imgMinute));
    final imgHour = await loadImageByProvider( AssetImage(config.imgHour));
    final imgPoint = await loadImageByProvider( AssetImage(config.imgPoint));
    ui.Image? imgSecond;
    if(config.imgSecond != null) {
      imgSecond = await loadImageByProvider(AssetImage(config.imgSecond!));
    }
    return ClockStyle(imgDisc: imgDisc, imgMinute: imgMinute, imgSecond: imgSecond, imgHour: imgHour, imgPoint: imgPoint, config: widget.buildConfig());
  }

  //通过ImageProvider读取Image
  Future<ui.Image> loadImageByProvider(ImageProvider provider, {ImageConfiguration config = ImageConfiguration.empty}) async {
    Completer<ui.Image> completer = Completer<ui.Image>(); //完成的回调
    late ImageStreamListener listener;
    ImageStream stream = provider.resolve(config); //获取图片流
    listener = ImageStreamListener((ImageInfo frame, bool sync) {
      //监听
      final ui.Image image = frame.image;
      completer.complete(image); //完成
      stream.removeListener(listener); //移除监听
    });
    stream.addListener(listener); //添加监听
    return completer.future; //返回
  }

}

class HandClock extends CustomPainter {

  final _paint = Paint();
  ClockStyle? data;

  late int hour12;
  late int minute;
  late int second;


  HandClock(this.data) {
    _paint.isAntiAlias = false;
    updateTime();
  }

  void updateTime() {
    final timeNow = DateTime.now();
    hour12 = timeNow.hour % 12;
    minute = timeNow.minute;
    second = timeNow.second;
  }


  @override
  void paint(Canvas canvas, Size size) {
    if(this.data == null) return;
    final data = this.data!;

    final imgDisc = data.imgDisc;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    Offset discOffset = Offset((size.width - imgDisc.width) / 2, (size.height - imgDisc.height) / 2);
    canvas.drawImage(imgDisc, discOffset, _paint);

    /// 绘制时针
    ui.PictureRecorder hourPicR = ui.PictureRecorder();
    Canvas hourCanvas = Canvas(hourPicR);
    hourCanvas.translate(centerX, centerY);
    hourCanvas.rotate(angleToRadians(hour12 * 30 + minute * 0.5));
    hourCanvas.drawImage(data.imgHour, Offset(- data.imgHour.width / 2.0, - data.imgHour.height / 1.0 + data.config.hourDistance), _paint);

    /// 绘制分针
    ui.PictureRecorder minutePicR = ui.PictureRecorder();
    Canvas minuteCanvas = Canvas(minutePicR);
    minuteCanvas.translate(centerX, centerY);
    minuteCanvas.rotate(angleToRadians(minute * 6 + second * 0.1));
    minuteCanvas.drawImage(data.imgMinute, Offset(- data.imgMinute.width / 2.0, - data.imgMinute.height / 1.0 + data.config.minuteDistance), _paint);

    /// 绘制秒针
    ui.PictureRecorder? secondPicR;
    if(data.imgSecond != null) {
      secondPicR = ui.PictureRecorder();
      Canvas secondCanvas = Canvas(secondPicR);
      secondCanvas.translate(centerX, centerY);
      secondCanvas.rotate(angleToRadians(second * 6));
      secondCanvas.drawImage(data.imgSecond!, Offset(-data.imgSecond!.width / 2.0, -data.imgSecond!.height / 1.0 + data.config.secondDistance), _paint);
    }

    /// 绘制圆心
    ui.PictureRecorder pointPicR = ui.PictureRecorder();
    Canvas pointCanvas = Canvas(pointPicR);
    pointCanvas.translate(centerX, centerY);
    pointCanvas.drawImage(data.imgPoint, Offset(- data.imgPoint.width / 2.0, - data.imgPoint.height / 2.0 ), _paint);

    canvas.drawPicture(hourPicR.endRecording());
    canvas.drawPicture(minutePicR.endRecording());
    if(secondPicR != null) {
      canvas.drawPicture(secondPicR.endRecording());
    }
    canvas.drawPicture(pointPicR.endRecording());
  }

  double angleToRadians(double angle) {
    return angle / 180 * 3.1415926;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}

