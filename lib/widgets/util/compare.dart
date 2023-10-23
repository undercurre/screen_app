class Compare {
  static List<List<T>> compareData<T>(List<T> cachedData, List<T> apiData) {
    Set<T> cachedDataSet = Set.from(cachedData);
    Set<T> apiDataSet = Set.from(apiData);
    Set<T> addedData = apiDataSet.difference(cachedDataSet);
    Set<T> removedData = cachedDataSet.difference(apiDataSet);

    return [addedData.toList(), removedData.toList()];
  }
}