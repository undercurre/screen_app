


class LanUtils {

  //  print(equal(['1','2','2'], ['1','2','3']));
//   print(equal(['1','3','2'], ['1','2','3']));
//   print(equal(['1','3','2'], ['1','2']));
//   print(equal({
//     '1': ['1','2','3'],
//     '2':123,
//     '3':{
//       '1': 1,
//       '2': 2,
//       '3':['1','2','3'],
//       '4': {
//         '1': 1,
//         '2': 2,
//         '3':['1','2','2']
//       }
//     }
//   }, {
//     '1': ['1','2','3'],
//     '2': 123,
//     '3':{
//       '1': 1,
//       '2': 2,
//       '3':['1','3','2'],
//       '4': {
//         '1': 1,
//         '2': 2,
//         '3':['1','2','3']
//       }
//     }
//   }));
  static bool equal(dynamic value1, dynamic value2, [int deep = 9223372036854775807]) {
    if (value1 is Map && value2 is Map) {
      if (deep == 0) {
        return true;
      }
      if (value1.keys.length != value2.keys.length) {
        return false;
      }
      bool equals = true;
      value1.forEach((key, elementValue) {
        equals &= equal(elementValue, value2[key], deep - 1);
      });
      return equals;
    } else if (value1 is List && value2 is List) {
      if (deep == 0) {
        return true;
      }
      bool result = true;
      for (var item1 in value1) {
        bool equals = false;
        for (var item2 in value2) {
          equals |= equal(item1, item2, deep - 1);
        }
        result &= equals;
      }
      if (!result) return false;

      result = true;
      for (var item1 in value2) {
        bool equals = false;
        for (var item2 in value1) {
          equals |= equal(item1, item2, deep - 1);
        }
        result &= equals;
      }
      return result;
    } else {
      return value1 == value2;
    }
  }

// value2 contain in value1
// 数值2 被 数值1 包含
  static bool mapContain(Map<String, dynamic> value1, Map<String, dynamic> value2) {
    bool equals = true;
    value2.forEach((key, elementValue) {
      equals &= equal(elementValue, value1[key]);
    });
    return equals;
  }

// 将collection2 融合到 collection1 上
  static Map<dynamic, dynamic> mapDeepMerge(
      Map<dynamic, dynamic> collection1, Map<dynamic, dynamic> collection2) {

    collection2.forEach((key2, value2) {
      if (collection1.containsKey(key2)) {
        var value1 = collection1[key2];
        if (value2 is Map && value1 is Map) {
          collection1[key2] = mapDeepMerge(value1, value2);
        } else {
          collection1[key2] = value2;
        }
      } else {
        collection1[key2] = value2;
      }
    });

    return collection1;
  }
}