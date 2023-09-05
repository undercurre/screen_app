import 'dart:convert';

import 'package:logger/logger.dart';
import 'dart:io';

// 定义日志文件最大保存的大小
const _maxFileOutputLength = 10 * 1024 * 1024;

class FileOutput extends LogOutput {
  final File file;
  final bool overrideExisting;
  final Encoding encoding;
  RandomAccessFile? randomAccessFile;

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
    }

    if(randomAccessFile!.positionSync() > _maxFileOutputLength) {
      randomAccessFile!.setPositionSync(0);
    }

    randomAccessFile!.flushSync();
  }

  @override
  void destroy() async {
    randomAccessFile?.closeSync();
  }

}

class Log {

  /// 日志台日志打印
  static final _consoleLogger = Logger(
      filter: ProductionFilter(),
      printer: PrettyPrinter(printTime: true),
      output: MultiOutput([
        ConsoleOutput(),
      ]),
      level: Level.info);

  /// 文件打印
  static final _fileLogger = Logger(
    filter: ProductionFilter(),
    printer: PrettyPrinter(printTime: true),
    output: MultiOutput([
      ConsoleOutput(),
      FileOutput(
          overrideExisting: true,
          file: File.fromUri(Uri.file(
              '/data/data/com.midea.light/cache/MideaLog.txt')))
    ]),
  );

  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _consoleLogger.i(message, error, stackTrace);
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _consoleLogger.e(message, error, stackTrace);
  }

  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _consoleLogger.d(message, error, stackTrace);
  }

  static void v(String message, [dynamic error, StackTrace? stackTrace]) {
    _consoleLogger.v(message, error, stackTrace);
  }

  static void file(String message, [dynamic error, StackTrace? stackTrace]) {
    _fileLogger.i(message, error, stackTrace);
  }
}
