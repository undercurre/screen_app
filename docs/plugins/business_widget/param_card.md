# 普通的带滑动条卡片

## 属性

| 参数name       | 类型          | 必传    | 默认值                                      | 描述       |
|--------------|-------------|-------|------------------------------------------|----------|
| activeColors | List<Color> | false | `[Color(0xFF267AFF), Color(0xFF267AFF)]` | 滑轨激活部分底色 |
| unit         | String      | false | '%'                                      | 值单位      |
| value        | num         | true  | -                                        | 当前值      |
| title        | String      | true  | -                                        | 卡片标题     |
| disabled     | Widget      | false | false                                    | 是否禁用操作   |
| duration     | Duration    | false | null                                     | 动画时长     |
| throttle     | Duration    | false | Duration(seconds: 1)                     | 动画时长     |

## 事件

| 参数name     | 类型                       | 必传    | 描述      |
|------------|--------------------------|-------|---------|
| onChanged  | void Function(num value) | false | 操作松手时的值 |
| onChanging | void Function(num value) | false | 操作时的值   |

