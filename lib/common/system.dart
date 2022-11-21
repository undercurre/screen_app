// 等待多久进入待机状态
List _standbyTime = [
  // {'value': 30, 'text': '30秒'},
  {'value': 60, 'text': '1分钟'},
  {'value': 180, 'text': '3分钟'},
  {'value': 300, 'text': '5分钟'},
  {'value': -1, 'text': '永不'},
];

Map weatherData = {
  'standbyTime': _standbyTime.first['value'],
  'weatherCode': '',
};

// 待机设置
class StandbySetting {
  static get standbyTime => weatherData['standbyTime'];

  static String get weatherCode => weatherData['weatherCode'];

  static set weatherCode(String code) {
    weatherData['weatherCode'] = code;
  }
}
