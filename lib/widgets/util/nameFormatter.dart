import '../../common/logcat_helper.dart';

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
}
