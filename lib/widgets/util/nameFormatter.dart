class NameFormatter {
  static String formatName(String inputName) {
    if (inputName.length > 4) {
      int strlen = inputName.length;
      return '${inputName.substring(0, 2)}...${inputName.substring(strlen - 1, strlen)}';
    } else {
      return inputName;
    }
  }
}
