import 'dart:convert';

import 'package:logger/logger.dart';
import 'dart:io';

// 定义日志文件最大保存的大小
const _maxFileOutputLength = 30 * 1024 * 1024;

class FileOutput extends LogOutput {
  final File file;
  final bool overrideExisting;
  final Encoding encoding;
  RandomAccessFile? randomAccessFile;
  int count = 1;

  FileOutput({
    required this.file,
    this.overrideExisting = false,
    this.encoding = utf8,
  }) {
    if(!file.existsSync()) {
      file.createSync(recursive: true, exclusive: false);
    }
  }

  @override
  void init() {
    randomAccessFile = file.openSync(mode: FileMode.writeOnlyAppend);
    if(randomAccessFile!.lengthSync() > _maxFileOutputLength) {
      randomAccessFile!.setPositionSync(0);
    }
  }

  @override
  void output(OutputEvent event) {
    if(randomAccessFile == null) return;

    for (var element in event.lines) {
      randomAccessFile!.writeStringSync('$element\n');
      count++;
    }

    if(randomAccessFile!.positionSync() > _maxFileOutputLength) {
      randomAccessFile!.setPositionSync(0);
    }

    try{
      if(count > 50) {
        randomAccessFile!.flushSync();
        count = 1;
      }
    } on Exception catch(error) {
      Log.e(error);
    }

  }

  @override
  void destroy() async {
    randomAccessFile?.closeSync();
    randomAccessFile = null;
  }

}

class MPrettyPrinter extends PrettyPrinter {

  MPrettyPrinter(): super(printTime: true);

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
      filter: ProductionFilter(),
      printer: MPrettyPrinter(),
      output: MultiOutput([
        ConsoleOutput(),
      ]),
      level: Level.verbose);

  /// 文件打印
  static final _fileLogger = Logger(
    filter: ProductionFilter(),
    printer: MPrettyPrinter(),
    output: MultiOutput([
      ConsoleOutput(),
      FileOutput(
          overrideExisting: true,
          file: File.fromUri(Uri.file(
              '/data/data/com.midea.light/cache/MideaLog.txt')))
    ]),
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
            file: File.fromUri(Uri.file(
                '/data/data/com.midea.light/cache/DevelopLog.txt')))
      ]),
      level: Level.nothing
  );

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _consoleLogger.w(message, error, stackTrace);
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _consoleLogger.i(message, error, stackTrace);
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _consoleLogger.e(message, error, stackTrace);
  }

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _consoleLogger.d(message, error, stackTrace);
  }

  static void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _consoleLogger.v(message, error, stackTrace);
  }

  static void file(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _fileLogger.i(message, error, stackTrace);
  }

  static void develop(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _developLogger.i(message, error, stackTrace);
  }

}
