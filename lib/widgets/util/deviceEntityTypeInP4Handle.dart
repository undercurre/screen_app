class DeviceEntityTypeInP4Handle {
  static String extractLowercaseEntityType(String inputString) {
    // 定义正则表达式模式，匹配DeviceEntityTypeInP4后面的单词
    final pattern = RegExp(r'DeviceEntityTypeInP4\.(\w+)');

    // 使用正则表达式查找匹配项
    final match = pattern.firstMatch(inputString);

    // 如果有匹配项，返回匹配的结果的小写形式，否则返回空字符串
    if (match != null) {
      return match.group(1)!.toLowerCase();
    } else {
      return '';
    }
  }
}
