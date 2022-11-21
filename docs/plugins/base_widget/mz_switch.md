# 开关组件

## 简介
通用的开关组件

## 属性

| 参数name             | 类型       | 必传    | 默认值   | 描述       |
|--------------------|----------|-------|-------|----------|
| value              | bool     | false | false | 开关状态     |
| disabled           | bool     | false | -     | 是否禁止操作   |
| activeColor        | Color    | false | -     | 滑轨激活底色   |
| inactiveColor      | Color    | false | -     | 滑轨未激活底色  |
| pointActiveColor   | Color    | false | -     | 圆球激活底色   |
| pointInactiveColor | Color    | false | -     | 圆圈未激活底色  |
| duration           | Duration | false | -     | 状态切换动画时间 |

## 事件

| 参数name | 类型                        | 必传    | 描述     |
|--------|---------------------------|-------|--------|
| onTap  | void Function(bool value) | false | 开关点击事件 |
