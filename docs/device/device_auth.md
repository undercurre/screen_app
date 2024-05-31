## 设备确权介绍文档

`背景`：所有的美居WiFi设备, 在第一次配网使用的时候，都需要经过用户确权才能使用。

`需求`：在设备需要确权时，提醒用户前往美居APP或者Homlux小程序。按照动图和文字指引，用户进行确权操作。

四寸屏处理逻辑：
1. 配置需要鉴权的设备列表
```dart
///#文件路径  /common/adapter/device_card_data_adapter.dart
/// 设备确权配置表
/// （一般普通的wifi设备都需判断确权）
const NeedCheckWaitLockAuthTypes = [
   AdapterType.wifiLight,   /// wifi灯
   AdapterType.wifiCurtain, /// wifi窗帘
   AdapterType.wifiAir,     /// wifi空调    
   AdapterType.wifiYuba,    /// wifi浴霸
   AdapterType.wifiLiangyi, /// wifi晾衣架
   AdapterType.wifiDianre,  /// 
   AdapterType.wifiRanre
];
```
2. 设置全局统一的鉴权拦截
```dart
///#文件路径  /common/adapter/device_card_data_adapter.dart
///#拦截方法  DeviceCardDataAdapter.fetchDataInSafety()
```
3. 根据鉴权结果，响应不同的逻辑
   1. 设备未鉴权
      1. `提示`设备未鉴权，且`未获取`设备详情数据
   2. 设备已鉴权
      1. `记录`设备鉴权，并且`成功获取`设备详情数据