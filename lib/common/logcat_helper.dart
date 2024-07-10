import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'dart:io';

Future<void> _openAndWriteFile(SendPort p) async {
  var receivePort2 = ReceivePort("[子线程 log-file-output]");
  p.send(receivePort2.sendPort);
  File? file;
  int fileLimit = 0;
  int count = 1;
  bool overrideExisting;
  RandomAccessFile? randomAccessFile;
  await for(final message in receivePort2) {
    switch(message['topic']) {
      case 'destroy':
        Isolate.exit();
        break;
      case 'create':
        overrideExisting = message['overrideExisting'];
        fileLimit = message['fileLimit'];
        String filePath = message['filePath'];
        file = File.fromUri(Uri.file(filePath));
        if(!file.existsSync()) {
          //recursive: 是否创建目录
          //exclusive: false创建文件并覆盖已存在的文件，true创建文件如果试先存在则报错
          file.createSync(recursive: true, exclusive: false);
        }
        break;
      case 'init':
        try {
          assert(file != null);
          randomAccessFile = file!.openSync(mode: FileMode.writeOnlyAppend);
          assert(fileLimit > 0);
          if (randomAccessFile.lengthSync() > fileLimit) {
            randomAccessFile.setPositionSync(0);
          }
        } catch(e) {
          debugPrint(e.toString());
          randomAccessFile = null;
        }
        break;
      case 'data':
        // debugPrint("out put");
        if(randomAccessFile == null) return;
        List<String> lines = message['messages'];

        /// 因开发者有可能会在外部调用 `> MideaLog.txt` 指令清空文件内容
        /// 方便使用 tail -f MideaLog.txt 查看日志
        if(randomAccessFile.lengthSync() == 0) {
          randomAccessFile.setPositionSync(0);
        }

        for (var element in lines) {
          randomAccessFile.writeStringSync('$element\n');
          count++;
        }

        if(randomAccessFile.positionSync() > fileLimit) {
          randomAccessFile.setPositionSync(0);
        }

        try{
          if(count > 50) {
            randomAccessFile.flushSync();
            count = 1;
          }
        } on Exception catch(error) {
          Log.e(error);
        }
        break;
    }
  }
  Isolate.exit();
}

class FileOutput extends LogOutput {
  final String filePath;
  final bool overrideExisting;
  final Encoding encoding;
  int fileLimit;

  SendPort? sendPort;
  late Isolate isolate;
  var tempCaches = <OutputEvent>[];

  FileOutput({
    required this.filePath,
    required this.fileLimit,
    this.overrideExisting = false,
    this.encoding = utf8,
  }) {

    () async {
      var receivePort1 = ReceivePort("log_file_output");
      isolate = await Isolate.spawn(_openAndWriteFile, receivePort1.sendPort);
      receivePort1.listen((message) {
        sendPort = message;
        sendPort?.send({
          'topic': 'create',
          'overrideExisting': overrideExisting,
          'fileLimit': fileLimit,
          'filePath': filePath
        });
        sendPort?.send({
          'topic': 'init'
        });
        for (var event in tempCaches) {
          sendPort!.send({
            'topic': 'data',
            'messages': event.lines
          });
        }
        tempCaches.clear();
      });
    }();
  }

  @override
  void init() {

  }

  @override
  void output(OutputEvent event) {
    if(sendPort != null) {
      sendPort!.send({
        'topic': 'data',
        'messages': event.lines
      });
    } else {
      /// 防止内存溢出，最多存放十条
      if(tempCaches.length <= 10) {
        tempCaches.add(event);
      }
    }
  }

  @override
  void destroy() async {
    sendPort?.send('destroy');
  }

}

class MPrettyPrinter extends PrettyPrinter {

  MPrettyPrinter(): super(printTime: true, errorMethodCount: 200);

  @override
  String getTime(DateTime time) {
    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }
    return '${twoDigits(time.month)}/${twoDigits(time.day)} ${super.getTime(time)}';
  }

}

class ProxyLogger {

  const ProxyLogger();

  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    Log.v(message, error, stackTrace);
  }
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    Log.d(message, error, stackTrace);
  }
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    Log.i(message, error, stackTrace);
  }
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    Log.w(message, error, stackTrace);
  }
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    Log.e(message, error, stackTrace);
  }
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    Log.i(message, error, stackTrace);
  }
}

const bool inProduction = bool.fromEnvironment('dart.vm.product');

class Log {
  /// 日志台日志打印
  static final _consoleLogger = Logger(
      filter: DevelopmentFilter(),
      printer: MPrettyPrinter(),
      output: MultiOutput([
        ConsoleOutput(),
      ]),
      level: Level.verbose);

  /// 文件打印
  static final _fileLogger = Logger(
    filter: ProductionFilter(),
    printer: SimplePrinter(printTime: true, colors: false),
    output: MultiOutput([
      FileOutput(
          overrideExisting: true,
          fileLimit: 30 * 1024 * 1024,
          filePath: '/data/data/com.midea.light/cache/MideaLog.txt'
          // file: File.fromUri(Uri.file(
          //     '/data/data/com.midea.light/cache/MideaLog.txt')))
      )]),
    level: Level.verbose
  );

  /// 文件打印
  static final _developLogger = Logger(
      filter: DevelopmentFilter(),
      printer: SimplePrinter(),
      output: MultiOutput([
        ConsoleOutput(),
        FileOutput(
            overrideExisting: true,
            fileLimit: 10 * 1024 * 1024,
            filePath: '/data/data/com.midea.light/cache/DevelopLog.txt'
        )]),
      level: Level.verbose
  );

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _consoleLogger.w(message, error, stackTrace);
    _fileLogger.w(message, error, stackTrace);
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _consoleLogger.i(message, error, stackTrace);
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _consoleLogger.e(message, error, stackTrace);
    _fileLogger.e(message, error, stackTrace);
  }

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _consoleLogger.d(message, error, stackTrace);
  }

  static void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _consoleLogger.v(message, error, stackTrace);
  }

  static void file(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _consoleLogger.w(message, error, stackTrace);
    _fileLogger.i(message, error, stackTrace);
  }

  static void debugFile(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint(message);
    _fileLogger.i(message, error, stackTrace);
  }

  static void develop(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _developLogger.i(message, error, stackTrace);
  }

}
