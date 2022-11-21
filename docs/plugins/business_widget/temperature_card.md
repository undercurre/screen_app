# 温度卡片

## 简介
温度调节卡片，卡片上部分是：温度-按钮 - 温度 - 温度+按钮，下部分是滑动条。
温度支持小数，默认以1为一步。


## 属性

| 参数name         | 类型       | 必传    | 默认值   | 描述     |
|----------------|----------|-------|-------|--------|
| minTemperature | num      | false | 10    | 挡位最小值  |
| maxTemperature | num      | false | 60    | 挡位最大值  |
| value          | num      | false | 30    | 挡位值    |
| step           | num      | false | 1     | 挡位值    |
| disabled       | Widget   | false | false | 是否禁用操作 |
| duration       | Duration | false | null  | 动画时长   |

## 事件

| 参数name    | 类型                       | 必传    | 描述                |
|-----------|--------------------------|-------|-------------------|
| onChanged | void Function(num value) | false | 操作滑动条松手时或者点击按钮时的值 |
