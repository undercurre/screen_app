# 滑动条

## 简介

支持渐变的一个滑动条，类似`dof-slider`

## 属性

| 参数name       | 类型               | 必传    | 默认值                                      | 描述                         |
|--------------|------------------|-------|------------------------------------------|----------------------------|
| value        | num              | true  |                                          | 滑动条当前值                     |
| step         | num              | false | 1                                        | 步长（为0无步长）                  |
| min          | num              | false | 0                                        | 滑动条最小值                     |
| max          | num              | false | 100                                      | 滑动条最大值                     |
| activeColors | `[Color, Color]` | false | `[Color(0xFF267AFF), Color(0xFF267AFF)]` | 滑动条渐变开始值和结束值               |
| width        | double           | false | 100                                      | 滑动条长度                      |
| height       | double           | false | 20                                       | 滑动条高度                      |
| radius       | double           | false | 10                                       | 圆角大小                       |
| ballRadius   | double           | false | 6                                        | 白色圆球半径                     |
| rounded      | bool             | false | false                                    | 两边是否半圆（只有为false，radius才生效） |
| disabled     | bool             | false | false                                    | 能否控制滑动条（不影响value传入）        |
| duration     | Duration         | false | null                                     | 值变化动画时长                    |

## 事件

| 参数name     | 类型                                          | 必传    | 描述           |
|------------|---------------------------------------------|-------|--------------|
| onChanging | void Function(num value, Color activeColor) | false | 滑动过程中的变化值    |
| onChanged  | void Function(num value, Color activeColor) | false | 松手或者触摸取消的结果值 |

## 注意点
value的值会根据step的小数点位置决定，比如step是0.1，那么value的值也会有一位小数。
滑动条的圆角值能通过radius设置，但是如果rounded是true，那么滑动条就是半圆，radius值失效。