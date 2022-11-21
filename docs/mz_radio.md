# 单选按钮-MzRadio<T>

### 简介
4寸屏定制风格组件radio。


### 基本用法

```dart
import '../../widgets/index.dart';

MzRadio<String>(
activeColor: const Color.fromRGBO(0, 145, 255, 1),
value: item.homegroupId,
groupValue: homeId,
onTap: (value) {
debugPrint('onTap: $value');
))
```

### 参数配置
| Prop | Type         | Required | Default                                    | Description |
|------|--------------|----------|--------------------------------------------|-------------|
| value | `T`          |`Yes`| -                                          | 按钮值         |
| activeColor | `Color`      |`No`| `Color.fromRGBO(0, 145, 255, 1)`           | 激活状态颜色      |
| size | `double`     |`No`| `28.0`                                     | 按钮大小        |
| groupValue | `T` |`Yes`| `-`                                        | 单选按钮组当前值    |
| disable | `Boolean`    |`No`| `false`                                    | 是否可点击       |

### 事件
| EventName | Type | Required |  Description |
|------|------|----------|-------------|
| onTap | `Function` | `No` | 点击时触发 |