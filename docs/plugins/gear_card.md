# 挡位卡片

## 简介
挡位调节卡片，带挡位刻度

## 属性

| 参数name   | 类型       | 必传    | 默认值   | 描述     |
|----------|----------|-------|-------|--------|
| minGear  | num      | false | 1     | 挡位最小值  |
| maxGear  | num      | false | 6     | 挡位最大值  |
| value    | num      | false | 3     | 挡位值    |
| title    | String   | false | '风速'  | 卡片标题   |
| disabled | Widget   | false | false | 是否禁用操作 |
| duration | Duration | false | null  | 动画时长   |

## 事件

| 参数name    | 类型                       | 必传    | 描述       |
|-----------|--------------------------|-------|----------|
| onChanged | void Function(num value) | false | 操作挡位松手时值 |

