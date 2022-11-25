# 带加减按钮卡片

## 简介

卡片带加减按钮和一个大号数字，步长支持小数，默认步长是1，可自定义标题或者无标题。

## 属性

| 参数name   | 类型       | 必传    | 默认值   | 描述     |
|----------|----------|-------|-------|--------|
| min      | num      | false | 10    | 挡位最小值  |
| max      | num      | false | 60    | 挡位最大值  |
| title    | String   | false | null  | 挡位最大值  |
| unit     | String   | false | '°C'  | 挡位最大值  |
| value    | num      | false | 30    | 挡位值    |
| step     | num      | false | 1     | 挡位值    |
| disabled | Widget   | false | false | 是否禁用操作 |
| duration | Duration | false | null  | 动画时长   |

## 事件

| 参数name    | 类型                       | 必传    | 描述                |
|-----------|--------------------------|-------|-------------------|
| onChanged | void Function(num value) | false | 操作滑动条松手时或者点击按钮后的值 |
