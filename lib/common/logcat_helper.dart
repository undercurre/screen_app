import 'package:logger/logger.dart';
import 'dart:io';

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
              '/storage/emulated/-1/Android/data/com.midea.light/cache/log.cat')))
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
