
class NameFormatter {
  static String formatName(String inputName, int fontCount) {
    if (inputName.length > fontCount && fontCount > 2) {
      int strlen = inputName.length;
      int prelen = fontCount - 2;
      return '${inputName.substring(0, prelen)}...${inputName.substring(strlen - 1, strlen)}';
    } else {
      return inputName;
    }
  }

  static String formatNamePopRoom(String inputName, int fontCount) {
    if (inputName.length > fontCount && fontCount > 5) {
      int strlen = inputName.length;
      int prelen = fontCount - 4;
      return '${inputName.substring(0, prelen)}...${inputName.substring(strlen - 4, strlen)}';
    } else {
      return inputName;
    }
  }

  /// 名称长度限制格式
  /// [<-----------maxLength----------->]
  /// [<-startLength->]...[<-endLength->]
  ///
  ///
  /// test-case: [testNameFormatCase]
  static String formLimitString(String str, int maxLength, int startLength, int endLength) {
    if (str.length <= maxLength) {
      return str;
    } else {
      if (startLength + endLength >= maxLength) {
        return str.substring(0, maxLength);
      } else {
        return '${str.substring(0, startLength)}...${str.substring(str.length - endLength)}';
      }
    }
  }
}
