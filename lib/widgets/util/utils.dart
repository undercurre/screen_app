enum SeekBarDragState {
  START,
  PROGRESS,
  FINISH,
}

typedef SeekBarProgress = void Function(int progress);
typedef SeekBarStarted = void Function();
typedef SeekBarFinished = void Function(int progress);

List<T> findDuplicates<T>(List<T> list1, List<T> list2) {
  // 创建一个集合来存储重复元素
  Set<T> duplicates = {};

  // 遍历第一个列表，并将其元素添加到集合中
  for (T item in list1) {
    duplicates.add(item);
  }

  // 创建一个列表来存储重复元素
  List<T> result = [];

  // 遍历第二个列表，并检查是否存在于集合中
  for (T item in list2) {
    if (duplicates.contains(item)) {
      result.add(item);
    }
  }

  return result;
}