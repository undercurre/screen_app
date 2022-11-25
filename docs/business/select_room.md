# 选择房间组件

### 简介
业务组件，查询当前家庭的房间列表，并room选择


### 基本用法

```dart
import '../../widgets/index.dart';

SelectRoom(onChange: (RoomInfo room) {
  debugPrint('SelectRoom: ${room.toJson()}');
}))
```

### 参数配置
| Prop | Type     | Required | Default                                    | Description |
|------|----------|----------|--------------------------------------------|-------------|
| value | `String` | `No`     | -                                          | 默认选中的房间Id   |


### 事件
| EventName | Type                      | Required | Description |
|------|---------------------------|----------|-------------|
| onChange | `Function(RoomInfo room)` | `No` | 选择的房间改变时触发  |