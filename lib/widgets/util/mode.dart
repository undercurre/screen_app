class ModeFilter {
  static List<String> removeString(List<String> inputList, String targetString) {
    // 检查数组中是否包含目标字符串
    if (inputList.contains(targetString)) {
      // 如果包含，移除目标字符串
      inputList.remove(targetString);
    }
    // 返回处理后的数组
    return inputList;
  }
}
