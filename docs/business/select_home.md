# 选择家庭组件

### 简介
业务组件，查询当前家庭列表，并选择


### 基本用法

```dart
import '../../widgets/index.dart';

SelectHome(
    value: Global.profile.homeInfo?.homegroupId ?? '',
    onChange: (HomeInfo home) {
    debugPrint('Select: ${home.toJson()}');
})),
```

### 参数配置
| Prop | Type     | Required | Default                                    | Description |
|------|----------|----------|--------------------------------------------|-------------|
| value | `String` | `No`     | -                                          | 默认选中的家庭Id   |


### 事件
| EventName | Type                      | Required | Description |
|------|---------------------------|----------|-------------|
| onChange | `Function(HomeInfo home)` | `No` | 选择的家庭改变时触发  |