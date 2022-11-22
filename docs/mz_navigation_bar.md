# 导航组件

## 简介
插件通用的顶部导航组件

## 属性

| 参数name | 类型     | 必传    | 默认值 | 描述        |
|--------|--------|-------|--|-----------|
| title  | String | false | `''` | 导航栏标题  |
| hasPower  | Widget | false  | - | 是否显示开关按钮 |
| power  | Widget | false  | - | 开关按钮值 |


## 事件

| 参数name        | 类型              | 必传    | 描述       |
|---------------|-----------------|-------|----------|
| onLeftBtnTap  | void Function() | false | 左箭头点击事件  |
| onPowerBtnTap | void Function() | false | 开关按钮点击事件 |
